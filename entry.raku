use Sparrow6::DSL;
use JSON::Fast;
use Sparrow6::Task::Repository;

BEGIN {
  say "container just started";
  say "some init logic here";
  Sparrow6::Task::Repository::Api.new().index-update;
}

directory '/app/git-state';

my $state-repo = "https://github.com/melezhik/kuberless-state.git";

while True {

  # checkout git repository with state
  git-scm $state-repo, %( :to</app/git-state>, :branch<main> );

  # load state from checked git repo 
  my $state = from-json("/app/git-state/state/state.json".IO.slurp);

  # load current state or initialize with empty HashMap
  my $current-state = "state.json".IO ~~ :e ?? from-json("state.json".IO.slurp) !! %();

  # override current state by new one
  copy "/app/git-state/state/state.json", "state.json";
        
  # get configuration variables from git state
  my $vars = $state<vars> || %();

  # deploy configuration file and check if it has changed
  my $res = task-run "deploy app config", "template6", %(
   :$vars, 
   :target</app/conf/app.config>,
   :template_dir</app/templates>,
   :template<app>,
  );

  # restart application if configuration
  # file has changed

  if $res<status> != 0 {
     task-run "service restart", "service-restart", %(
        :pid<app.pid>
     );
  }

  # deploy new version of application
  # if version has changed

  if $state<version> ne $current-state<version> {

    task-run "app stop", "app-stop", %(
      :pid<app.pid>
    );

    task-run "utils/curl", "curl", %(
      args => [
        %( 
          :output<bin/app>,
        ),
        [
          'silent',
          'location'
       ],
        $state<distro-url>
      ]
     );
     task-run "app start", "app-start", %(
        :pid<app.pid>,
        :bin<bin/app>
     );
  }

  my $s = task-run "check app is alive", "http-status";

  # raise an exception if application is not healthy
  # so singnaling kubernetes it should start a new container

  die "application is not healthy" unless $s<OK>;

  sleep(60); # sleep for 1 minute, could be configurable

}

LEAVE {
  say "container stopped or crashed";
  say "some clean up logic here";
}

