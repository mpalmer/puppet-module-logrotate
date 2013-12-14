require 'spec_helper'

describe "logrotate::system" do
	let(:title) { "rspec" }
	
	context "no options" do
		it "installs the package" do
			expect(subject).
			  to contain_package("logrotate").
			  with_ensure("present")
		end
	end
end
