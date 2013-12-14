# Configure the log rotation system.
#
# Takes no attributes at present, and doesn't care about the namevar.
define logrotate::system() {
	package { "logrotate":
		ensure => present
	}
}
