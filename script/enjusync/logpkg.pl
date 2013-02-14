sub wrt_log {

use vars qw/$ModuleName $Facility/;

# モジュールの読み込み
use Sys::Syslog;

# 引数
my $prog_name = $_[0];
my $priority = $_[1];
my $message = $_[2];
my $prio = uc $priority;

openlog($ModuleName, 'cons,pid', $Facility);

syslog($priority, "%s", "[$prio]:$prog_name:$message");

closelog();

}
1;
