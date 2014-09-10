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
#  * `copy` (boolean or string; default `false`)
#
#     If set to `true`, then the `copy` directive will be set in the
#     logrotate configuration fragment (that is, the log file will be
#     copied, rather than moved, and the original log file will be left
#     untouched).  If set to `"truncate"`, then the `copytruncate` directive
#     will be set in the logrotate configuration fragment, and so the log
#     file will copied and then truncated (which can result in loss of log
#     data).  Note that `copy` and `create` cannot both be set.
#
#  * `create` (string; optional; default `undef`)
#
#     If a non-`undef` value, it will be passed as-is to the `create`
#     parameter in the log rotation config.  The usual value for this is
#     `"<mode> <user> <group>"`.  If `undef`, no `create` parameter will be
#     set in the configuration.  Note that `copy` and `create` cannot both
#     be set.
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
	$copy               = false
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
	if $copy and $create {
		fail "Only one of \$copy and \$create can be set"
	}

	$logrotate_rule_logs = maybe_split($logs, "\s+")

	if $compress {
		if $compress == "delayed" {
			$lr_compress = { "compress" => "", "delaycompress" => "" }
		} else {
			$lr_compress = { "compress" => "" }
		}
	} else {
		$lr_compress = { "nocompress" => "" }
	}

	if $copy == "truncate" {
		$lr_copy = { "copytruncate" => "" }
	} elsif $copy == true {
		$lr_copy = { "copy" => "" }
	} elsif $copy == false {
		# noop
		$lr_copy = {}
	} else {
		fail "Unknown value for \$copy: '$copy'"
	}

	if $create {
		$lr_create = { "create" => $create }
	} else {
		$lr_create = { }
	}

	if $frequency == "daily" or $frequency == "weekly" or
	   $frequency == "monthly" or $frequency == "yearly" {
		$lr_frequency = { "$frequency" => "" }
	} else {
		fail("Invalid frequency for Logrotate::Rule[${name}]: '${frequency}'")
	}

	$lr_rotate = { "rotate" => $keep }

	if $missingok {
		$lr_missingok = { "missingok" => "" }
	} else {
		$lr_missingok = { "nomissingok" => "" }
	}

	if $rotate_if_empty {
		$lr_ifempty = { "ifempty" => "" }
	} else {
		$lr_ifempty = { "notifempty" => "" }
	}

	if $sharedscripts {
		$lr_sharedscripts = { "sharedscripts" => "" }
	} else {
		$lr_sharedscripts = { "nosharedscripts" => "" }
	}

	$logrotate_rule_args = merge($lr_compress,
	                             $lr_copy,
	                             $lr_create,
	                             $lr_frequency,
	                             $lr_rotate,
	                             $lr_missingok,
	                             $lr_ifempty,
	                             $lr_sharedscripts
	                            )

	if $prerotate_script {
		$lr_script_prerotate = { "prerotate" => $prerotate_script }
	} else {
		$lr_script_prerotate = { }
	}

	if $postrotate_script {
		$lr_script_postrotate = { "postrotate" => $postrotate_script }
	} else {
		$lr_script_postrotate = { }
	}

	if $firstaction_script {
		$lr_script_firstaction = { "firstaction" => $firstaction_script }
	} else {
		$lr_script_firstaction = { }
	}

	if $lastaction_script {
		$lr_script_lastaction = { "lastaction" => $lastaction_script }
	} else {
		$lr_script_lastaction = { }
	}

	$logrotate_rule_scripts = merge($lr_script_prerotate,
	                                $lr_script_postrotate,
	                                $lr_script_firstaction,
	                                $lr_script_lastaction
	                               )

	file { "/etc/logrotate.d/${name}":
		ensure => file,
		content => template("logrotate/etc/logrotate.d/rule")
	}
}
