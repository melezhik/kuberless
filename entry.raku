use Sparrow6::DSL;
use JSON::Fast;


BEGIN {
  say "container just started";
  say "some init logic here";
}

directory 'state';

while True {

  # checkout git repository with state
  git-scm 'https://git.local/application/app.git', %( :to<state> );

  # load state from checked git repo 
  my $state = from-json("state/state.json".IO.slurp);

  # load current state or initialize with empty HashMap
  my $current-state = "state.json".IO ~~ :e ?? from-json("state.json".IO.slurp) !! %();

  # override current state by new one
  copy "state/state.json", "state.json";
        
  # get configuration variables from git state
  my $vars = $state<vars>;

  # deploy configuration file and check if it has changed
  my $res = task-run "deploy app config", "template6", %(
   :$vars, 
   :target<app.config>,
   :template_dir<templates>,
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

