# -*- cperl -*-

use Test::More;
use Git;
use LWP::Simple;
use File::Slurper qw(read_text);
use Net::Ping;
use Term::ANSIColor qw(:constants);
use JSON;

use v5.14; # For say

my $repo = Git->repository ( Directory => '.' );
my $diff = $repo->command('diff','HEAD^1','HEAD');
my $diff_regex = qr/a\/proyectos\/(\d)\.md/;
my $github;

SKIP: {
  my ($this_hito) = ($diff =~ $diff_regex);
  skip "No hay envío de proyecto", 5 unless defined $this_hito;
  my $diag=<<EOC;

"Failed test" indica que no se cumple la condición indicada
Hay que corregir el envío y volver a hacer el pull request,
aumentando en uno el número de la versión del hito en el
fichero correspondiente.

EOC
  diag $diag;
  my @files = split(/diff --git/,$diff);
  my ($diff_hito) = grep( /$diff_regex/, @files);
  say "Tratando diff\n\t$diff_hito";
  my @lines = split("\n",$diff_hito);
  my @adds = grep(/^\+[^+]/,@lines);
  is( $#adds, 0, "Añade sólo una línea");
  my $url_repo;
  if ( $adds[0] =~ /\(http/ ) {
    ($url_repo) = ($adds[0] =~ /\((http\S+)\)/);
  } else {
    ($url_repo) = ($adds[0] =~ /^\+.+(http\S+)\b/s);
  }
  diag(check( "Encontrado URL del repo $url_repo" ));
  say $url_repo;
  isnt($url_repo,"","El envío incluye un URL");
  like($url_repo,qr/github.com/,"El URL es de GitHub");
  my ($user,$name) = ($url_repo=~ /github.com\/(\S+)\/(.+)/);
  ok( fichero_objetivos($user), "$user ha enviado objetivos" ); # Test 4
  my $repo_dir = "/tmp/$user-$name";
  if (!(-e $repo_dir) or  !(-d $repo_dir) ) {
    mkdir($repo_dir);
    `git clone $url_repo $repo_dir`;
  }
  my $student_repo =  Git->repository ( Directory => $repo_dir );
  my @repo_files = $student_repo->command("ls-files");
  say "Ficheros\n\t→", join( "\n\t→", @repo_files);
  isnt( grep(/proyectos\/0.md/, @repo_files), 1, "No es el repositorio de la asignatura");

  # Necesitamos el README a partir de ahora.
  my $README =  read_text( "$repo_dir/README.md");
  unlike( $README, qr/[hH]ito/, "El README no debe incluir la palabra hito");

  # Comprueba que se use el nombre correcto para los ficheros de requisitos si existen
  my $with_pip = grep(/req\w+\.txt/, @repo_files);
  if ($with_pip) {
     ok( grep( /requirements.txt/, @repo_files), "Fichero de requisitos de Python con nombre correcto" );
   }

  if ( $this_hito > 1 ) { # Comprobar milestones y eso
    doing("hito 2");
    isnt( grep( /.travis.yml/, @repo_files), 0, ".travis.yml presente" );
    my $travis_domain = travis_domain( $README, $user, $name );
    ok( $travis_domain =~ /(com|org)/ , "Está presente el badge de Travis con enlace al repo correcto");
    if ( $travis_domain =~ /(com|org)/ ) {
      is( travis_status($README), 'Passing', "Los tests deben pasar en Travis");
    }

    my ($buildtool) = ($README =~ m{(?:buildtool:)[^\n]+(\S+)\s+});
    isnt( grep( /$buildtool/, @repo_files), 0, "$buildtool presente" );
  }
  
  if ( $this_hito > 2 ) { # Despliegue en algún lado
    $README =  read_text( "$repo_dir/README.md");
  SKIP: {
      skip "Ya en el hito siguiente", 2 unless $this_hito == 2;

      my ($deployment_url) = ($README =~ m{(?:[Dd]espliegue|[Dd]eployment)[^\n]+(https://\S+)\b});
      if ( $deployment_url ) {
	diag "☑ Hallado URL de despliegue $deployment_url";
      } else {
	diag "✗ Problemas extrayendo URL de despliegue";
      }
      ok( $deployment_url, "URL de despliegue hito 2");
      my $status = get($deployment_url);
      if ( ! $status || $status =~ /html/ ) {
	$status = get( "$deployment_url/status"); # Por si acaso han movido la ruta
      }
      ok( $status, "Despliegue hecho en $deployment_url" );
      say "Respuesta ", $status;
      my $status_ref = from_json( $status );
      like ( $status_ref->{'status'}, qr/[Oo][Kk]/, "Status $status de $deployment_url correcto");
    }
  }

  if ( $this_hito > 2 ) { # Comprobar provisionamiento
    ok( grep( /.yml/, @repo_files), "Hay algún playbook en YAML presente" );
    ok( grep( /provision/, @repo_files), "Hay un directorio 'provision'" );
    ok( grep( m{provision/\w+}, @repo_files), "El directorio 'provision' no está vacío" );

    # Comprueba que se ha desplegado en una IP
    my ($deployment_ip) = ($README =~ /MV:\s*\b(\S+)\b\s+/);
    unlike($deployment_ip, qr/http/, "$deployment_ip no es una URL sino una IP");
  SKIP: {
      skip "Ya en el hito siguiente", 2 unless $this_hito == 3;
      
      check_ip($deployment_ip);
      my $status = get("http://$deployment_ip/");
      my $status_ref = from_json( $status );
      like ( $status_ref->{'status'}, qr/[Oo][Kk]/, "Status $status de $deployment_ip correcto");
    }
  }
  
  if ( $this_hito > 3 ) { # Comprobar script para acopiar las máquinas 
    isnt( grep( /acopio.sh/, @repo_files), 0, "Está el script de aprovisionamiento" );
    my ($deployment_ip) = ($README =~ /MV2:\s*\b(\S+)\b\s+/);
    unlike($deployment_ip, qr/http/, "$deployment_ip no es una URL sino una IP");
    SKIP: {
      skip "Ya en el hito siguiente", 1 unless $this_hito == 4;
      check_ip($deployment_ip);
      my $status = get("http://$deployment_ip/");
      my $status_ref = from_json( $status );
      like ( $status_ref->{'status'}, qr/[Oo][Kk]/, "Status $status de $deployment_ip correcto");
    };
  }

  if ( $this_hito > 4 ) { # Comprobar script para acopiar las máquinas
    isnt( grep( /orquestacion/, @repo_files), 0, "Hay un directorio 'orquestacion'" );
    
    isnt( grep( m{orquestacion/Vagrantfile}, @repo_files), 0, "El directorio 'orquestacion' tiene un fichero 'Vagrantfile'" );
    my $vagrantfile = read_text( "$repo_dir/orquestacion/Vagrantfile");
    like($vagrantfile,qr/vm.provision/,"El Vagrantfile incluye provisionamiento");

    my ($deployment_ip) = ($README =~ /Despliegue Vagrant:\s*(\S+)\s+/);
  SKIP: {
      skip "Ya en el hito siguiente", 1 unless $this_hito < 5;
      check_ip($deployment_ip);
    }
  }

  if ( $this_hito > 5 ) { # Despliegue en algún lado
    my ($deployment_url) = ($README =~ /(?:[Cc]ontenedor|[Cc]ontainer).+(https?:..\S+)\b/);
    if ( $deployment_url ) {
      diag "☑ Detectado URL de despliegue $deployment_url";
    } else {
      diag "✗ Problemas detectando URL de despliegue";
    }
    isnt( $deployment_url, "", "URL de despliegue hito 5");
    my $status = get "$deployment_url/status";
    isnt( $status, undef, "Despliegue hecho en $deployment_url" );
    my $status_ref = from_json( $status );
    like ( $status_ref->{'status'}, qr/[Oo][Kk]/, "Status de $deployment_url correcto");
    ok( grep( /Dockerfile/, @repo_files), "Dockerfile presente" );

    my ($dockerhub_url) = ($README =~ m{(https://hub.docker.com/r/\S+)\b});
    diag "Detectado URL de Docker Hub '$dockerhub_url'";
    my $dockerfile = get "$dockerhub_url/Dockerfile";
    ok( $dockerfile, "Dockerfile actualizado y en Docker Hub");
  }

};

done_testing();


# ------------------------------- Subs -----------------------------------

sub fichero_objetivos {
  my $user = shift;
  my @ficheros_objetivos = glob "objetivos/*.md";
  my @enviados = map { lc } @ficheros_objetivos;
  my $lc_user = lc $user;
  return grep( /$lc_user/, @enviados);
}

sub check {
  return BOLD.GREEN ."✔ ".RESET.join(" ",@_);
}

sub fail_x {
  return BOLD.MAGENTA."✘".RESET.join(" ",@_);
}

sub travis_domain {
  my ($README, $user, $name) = @_;
  my ($domain) = ($README =~ /.Build Status..https:\/\/travis-ci.(\w+)\/$user\/$name\.svg.+$name\)/);
  return $domain;
}

sub travis_status {
  my $README = shift;
  my ($build_status) = ($README =~ /Build Status..([^\)]+)\)/);
  my $status_svg = `curl -L -s $build_status`;
  return $status_svg =~ /passing/?"Passing":"Fail";
}

sub check_ip {
  my $ip = shift;
  if ( $ip ) {
    diag "\n\t".check( "Detectada dirección de despliegue $ip" )."\n";
  } else {
    diag "\n\t".fail_x( "Problemas detectando dirección de despliegue" )."\n";
  }
  my $pinger = Net::Ping->new();
  $pinger->port_number(22); # Puerto ssh
  isnt($pinger->ping($ip), 0, "$ip es alcanzable");
}
