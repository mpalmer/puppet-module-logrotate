require 'spec_helper'

describe "logrotate::rule" do
	let(:title) { "rspec" }
	
	context "no options" do
		it "bombs" do
			expect { should contain_file("/error") }.
			  to raise_error(Puppet::Error,
			       /Must pass logs to Logrotate::Rule\[rspec\]/
			     )
		end
	end
	
	context "with just logs" do
		let(:params) { { :logs => "/var/log/something_funny.log" } }
		
		it "creates the config file" do
			expect(subject).
			  to contain_file("/etc/logrotate.d/rspec")
		end
		
		it "warns people about modifying it" do
			expect(subject).
			  to contain_file("/etc/logrotate.d/rspec").
			  with_content(/THIS FILE IS AUTOMATICALLY DISTRIBUTED BY PUPPET/)
		end
		
		it "specifies the log file" do
			expect(subject).
			  to contain_file("/etc/logrotate.d/rspec").
			  with_content(%r{/var/log/something_funny.log \{})
		end

		it "specifies compression is enabled" do
			expect(subject).
			  to contain_file("/etc/logrotate.d/rspec").
			  with_content(/^\s*compress\s*$/)
		end
		
		it "does not that compression is delayed" do
			expect(subject).
			  to contain_file("/etc/logrotate.d/rspec").
			  without_content(/^\s*delaycompress\s*$/)
		end
		
		it "specifies frequency is daily" do
			expect(subject).
			  to contain_file("/etc/logrotate.d/rspec").
			  with_content(/^\s*daily\s*$/)
		end
		
		it "specifies 7 rotations' retention" do
			expect(subject).
			  to contain_file("/etc/logrotate.d/rspec").
			  with_content(/^\s*rotate\s+7\s*$/)
		end
		
		it "specifies that missing files are OK" do
			expect(subject).
			  to contain_file("/etc/logrotate.d/rspec").
			  with_content(/^\s*missingok\s*$/)
		end

		it "specifies rotation on empty" do
			expect(subject).
			  to contain_file("/etc/logrotate.d/rspec").
			  with_content(/^\s*ifempty\s*$/)
		end

		it "specifies no sharing of scripts" do
			expect(subject).
			  to contain_file("/etc/logrotate.d/rspec").
			  with_content(/^\s*nosharedscripts\s*$/)
		end
	end
	
	context "with multiple logs in an array" do
		let(:params) { { :logs => ["/var/log/foo.log",
		                           "/var/log/bar.log"
		                          ]
		             } }
		
		it "specifies the first log file" do
			expect(subject).
			  to contain_file("/etc/logrotate.d/rspec").
			  with_content(%r{/var/log/foo.log })
		end

		it "specifies the second log file" do
			expect(subject).
			  to contain_file("/etc/logrotate.d/rspec").
			  with_content(%r{/var/log/bar.log })
		end
	end
	
	context "with `compress => delayed`" do
		let(:params) { { :logs     => "/var/log/foo.log",
		                 :compress => "delayed"
		             } }
		
		it "sets compress" do
			expect(subject).
			  to contain_file("/etc/logrotate.d/rspec").
			  with_content(/^\s*compress\s*$/)
		end

		it "sets delaycompress" do
			expect(subject).
			  to contain_file("/etc/logrotate.d/rspec").
			  with_content(/^\s*delaycompress\s*$/)
		end
	end

	context "with `compress => false`" do
		let(:params) { { :logs     => "/var/log/foo.log",
		                 :compress => false
		             } }
		
		it "sets nocompress" do
			expect(subject).
			  to contain_file("/etc/logrotate.d/rspec").
			  with_content(/^\s*nocompress\s*$/)
		end

		it "does not set compress" do
			expect(subject).
			  to contain_file("/etc/logrotate.d/rspec").
			  without_content(/^\s*compress\s*$/)
		end

		it "does not set delaycompress" do
			expect(subject).
			  to contain_file("/etc/logrotate.d/rspec").
			  without_content(/^\s*delaycompress\s*$/)
		end
	end

	context "with `create`" do
		let(:params) { { :logs   => "/var/log/foo.log",
		                 :create => "0640 root adm"
		             } }
		
		it "writes the config parameter" do
			expect(subject).
			  to contain_file("/etc/logrotate.d/rspec").
			  with_content(/create\s+0640 root adm\s*$/)
		end
	end

	context "with `frequency => weekly`" do
		let(:params) { { :logs      => "/var/log/foo.log",
		                 :frequency => "weekly"
		             } }
		
		it "sets `weekly`" do
			expect(subject).
			  to contain_file("/etc/logrotate.d/rspec").
			  with_content(/^\s*weekly\s*$/)
		end

		%w{daily monthly yearly}.each do |f|
			it "does not set `#{f}`" do
				expect(subject).
				  to contain_file("/etc/logrotate.d/rspec").
				  without_content(/^\s*#{f}\s*$/)
			end
		end
	end

	context "with `frequency => monthly`" do
		let(:params) { { :logs      => "/var/log/foo.log",
		                 :frequency => "monthly"
		             } }
		
		it "sets `monthly`" do
			expect(subject).
			  to contain_file("/etc/logrotate.d/rspec").
			  with_content(/^\s*monthly\s*$/)
		end

		%w{daily weekly yearly}.each do |f|
			it "does not set `#{f}`" do
				expect(subject).
				  to contain_file("/etc/logrotate.d/rspec").
				  without_content(/^\s*#{f}\s*$/)
			end
		end
	end

	context "with `frequency => yearly`" do
		let(:params) { { :logs      => "/var/log/foo.log",
		                 :frequency => "yearly"
		             } }
		
		it "sets `yearly`" do
			expect(subject).
			  to contain_file("/etc/logrotate.d/rspec").
			  with_content(/^\s*yearly\s*$/)
		end

		%w{daily weekly monthly}.each do |f|
			it "does not set `#{f}`" do
				expect(subject).
				  to contain_file("/etc/logrotate.d/rspec").
				  without_content(/^\s*#{f}\s*$/)
			end
		end
	end

	context "with `frequency => invalid`" do
		let(:params) { { :logs      => "/var/log/foo.log",
		                 :frequency => "invalid"
		             } }
		
		it "bombs" do
			expect { should contain_file("/error") }.
			  to raise_error(Puppet::Error,
			       /Invalid frequency for Logrotate::Rule\[rspec\]: 'invalid'/
			     )
		end
	end

	context "with `keep => 42`" do
		let(:params) { { :logs => "/var/log/foo.log",
		                 :keep => 42
		             } }
		
		it "sets `rotate 42`" do
			expect(subject).
			  to contain_file("/etc/logrotate.d/rspec").
			  with_content(/^\s*rotate\s+42\s*$/)
		end
	end

	context "with `missingok => false`" do
		let(:params) { { :logs      => "/var/log/foo.log",
		                 :missingok => false
		             } }
		
		it "sets `nomissingok`" do
			expect(subject).
			  to contain_file("/etc/logrotate.d/rspec").
			  with_content(/^\s*nomissingok\s*$/)
		end

		it "does not set `missingok`" do
			expect(subject).
			  to contain_file("/etc/logrotate.d/rspec").
			  without_content(/^\s*missingok\s*$/)
		end
	end

	context "with `rotate_if_empty => false`" do
		let(:params) { { :logs            => "/var/log/foo.log",
		                 :rotate_if_empty => false
		             } }
		
		it "sets `notifempty`" do
			expect(subject).
			  to contain_file("/etc/logrotate.d/rspec").
			  with_content(/^\s*notifempty\s*$/)
		end

		it "does not set `ifempty`" do
			expect(subject).
			  to contain_file("/etc/logrotate.d/rspec").
			  without_content(/^\s*ifempty\s*$/)
		end
	end

	context "with `sharedscripts => true`" do
		let(:params) { { :logs          => "/var/log/foo.log",
		                 :sharedscripts => true
		             } }
		
		it "sets `sharedscripts`" do
			expect(subject).
			  to contain_file("/etc/logrotate.d/rspec").
			  with_content(/^\s*sharedscripts\s*$/)
		end

		it "does not set `nosharedscripts`" do
			expect(subject).
			  to contain_file("/etc/logrotate.d/rspec").
			  without_content(/^\s*nosharedscripts\s*$/)
		end
	end

	%w{prerotate postrotate firstaction lastaction}.each do |attr|
		context "with `#{attr}_script` set" do
			let(:params) { { :logs            => "/var/log/foo.log",
								  "#{attr}_script" => "echo 'I am the walrus'"
							 } }
			
			it "defines the script" do
				expect(subject).
				  to contain_file("/etc/logrotate.d/rspec").
				  with_content(/^\s*#{attr}\s*\n\s*echo 'I am the walrus'\s*\n\s*endscript\s*$/)
			end
		end
	end
end
