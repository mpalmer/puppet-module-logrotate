# Configure a logrotate rule.
#
# Writes out a configuration fragment to the system's log rotation fragment
# directory (usually `/etc/logrotate.d`) that will rotate the set of
# files specified by the `logs` attribute.
#
# To reduce the amount of needless faffing around, this type does not
# faithfully reproduce every possible configuration option in
# `logrotate.conf`.  In general, attributes have names that match with their
# in-file equivalents, but the possible values (and sometimes the defaults)
# are sometimes different from those specified in `logrotate.conf`(5).
#
# Available attributes are:
#
#  * `title` (string; *namevar*)
#
#     Defines the base name of the file which will be created to contain
#     the logrotate configuration.  So you probably don't want to use
#     fancy characters like forward slash.
#
#  * `logs` (string or array of strings; required)
#
#     List the log files to be rotated by this rule.  This can either
#     be a single string (possibly with more than one log file path,
#     separated by spaces) or an array of paths.  Each path can be a
#     glob, to match multiple log files.
#
#  * `compress` (boolean or string; default `true`)
#
#     This attribute can be either the boolean values `true` or `false`,
#     or else the string `"delayed"`.  The boolean values simply enable or
#     disable log compression, respectively.  The value `"delayed"` specifies
#     that compression be enabled, but that the most recently rotated log file
#     not be compressed.
#
#  * `create` (string; optional; default `undef`)
#
#     If a non-`undef` value, it will be passed as-is to the `create`
#     parameter in the log rotation config.  The usual value for this is
#     `"<mode> <user> <group>"`.  If `undef`, no `create` parameter will be
#     set in the configuration.
#
#  * `frequency` (string; optional; default `"daily"`)
#
#     How often to rotate the log.  Valid values are `"daily"` (the
#     default), `"weekly"` (rotate if at least a week has passed since the
#     last rotation), `"monthly"` (rotate the first time logrotate is run in
#     a given month), or `"yearly"` (rotate if the current year is greater
#     than the year in which the logfile was last rotated).
#
#  * `keep` (integer; optional; default `7`)
#
#     How many old rotations of the log file to keep on hand before they
#     are deleted (or mailed; see the `mailto` attribute).
#
#  * `missingok` (boolean; optional; default `true`)
#
#     Whether or not logrotate should freak out if no files match the files
#     specified in the `logs` directive.
#
#  * `rotate_if_empty` (boolean; optional; default `true`)
#
#     If set to `true`, then the log file will be rotated even if it is of
#     zero size.  Otherwise, logs will be left alone if nothing has been
#     written to them, which can result in different files of the same
#     "rotation age" having different time periods of data in them.
#
#  * `sharedscripts` (boolean; optional; default `false`)
#
#     When more than one log file is rotated as a result of a single
#     logrotate rule (either because multiple log files were specified, or
#     because a glob matched multiple files), logrotate needs to know
#     whether to run any scripts once after all the logfiles have been
#     rotated, or after each logfile is rotated individually.  This parameter
#     controls that behaviour.
#
#     There are several consequences of this setting; rather than duplicating
#     information, I'll just point you to the `logrotate.conf`(5) man page to
#     see for yourself (search for `sharedscripts`).
#
#  * `prerotate_script` (string; optional; default `undef`)
#
#     If set to something other than `undef`, the value of this attribute will
#     be specified as a script to be executed before the logs specified in this
#     rule are rotated.
#
#  * `postrotate_script` (string; optional; default `undef`)
#
#     If set to something other than `undef`, the value of this attribute will
#     be specified as a script to be executed after the logs specified in this
#     rule are rotated.
#
#  * `firstaction_script` (string; optional; default `undef`)
#
#     If set to something other than `undef`, the value of this attribute
#     will be specified as a script to be executed before any of the logs
#     specified in this rule are rotated, and also before `prerotate_script`
#     is executed.
#
#  * `lastaction_script` (string; optional; default `undef`)
#
#     If set to something other than `undef`, the value of this attribute
#     will be specified as a script to be executed after all the logs
#     specified in this rule are rotated, and also after `postrotate_script`
#     has completed.
#
define logrotate::rule(
	$logs,
	$compress           = true,
	$create             = undef,
	$frequency          = "daily",
	$keep               = 7,
	$missingok          = true,
	$rotate_if_empty    = true,
	$sharedscripts      = false,
	$prerotate_script   = undef,
	$postrotate_script  = undef,
	$firstaction_script = undef,
	$lastaction_script  = undef
) {
	$logrotate_rule_logs = maybe_split($logs, "\s+")
	$logrotate_rule_args = {}
	
	if $compress {
		$logrotate_rule_args["compress"] = ""
		
		if $compress == "delayed" {
			$logrotate_rule_args["delaycompress"] = ""
		}
	} else {
		$logrotate_rule_args["nocompress"] = ""
	}
	
	if $create {
		$logrotate_rule_args["create"] = $create
	}
	
	if $frequency == "daily" or $frequency == "weekly" or
	   $frequency == "monthly" or $frequency == "yearly" {
		$logrotate_rule_args[$frequency] = ""
	} else {
		fail("Invalid frequency for Logrotate::Rule[${name}]: '${frequency}'")
	}
	
	$logrotate_rule_args["rotate"] = $keep
	
	if $missingok {
		$logrotate_rule_args["missingok"] = ""
	} else {
		$logrotate_rule_args["nomissingok"] = ""
	}
	
	if $rotate_if_empty {
		$logrotate_rule_args["ifempty"] = ""
	} else {
		$logrotate_rule_args["notifempty"] = ""
	}
	
	if $sharedscripts {
		$logrotate_rule_args["sharedscripts"] = ""
	} else {
		$logrotate_rule_args["nosharedscripts"] = ""
	}
	
	$logrotate_rule_scripts = {}
	
	if $prerotate_script {
		$logrotate_rule_scripts["prerotate"] = $prerotate_script
	}
	if $postrotate_script {
		$logrotate_rule_scripts["postrotate"] = $postrotate_script
	}
	if $firstaction_script {
		$logrotate_rule_scripts["firstaction"] = $firstaction_script
	}
	if $lastaction_script {
		$logrotate_rule_scripts["lastaction"] = $lastaction_script
	}
	
	file { "/etc/logrotate.d/${name}":
		ensure => file,
		content => template("logrotate/etc/logrotate.d/rule")
	}
}
