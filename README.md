This module manages the configuration of the well-known and
universally-loved `logrotate` program.  It'll ensure that `logrotate` is
installed and active (via the `logrotate::system` type), and provides the
`logrotate::rule` type to setup log rotation rules for individual log files. 
See the documentation for these types for details on how to use each type.
