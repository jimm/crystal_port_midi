# All of the error-handling specs are collected here. That's because we want
# to be able to skip them. Why? Well, it's possible for the Portmidi library
# to be compiled with a flag (`PM_CHECK_ERRORS`) that tells it to print an
# error message, prompt the user to hit ENTER, and exit immediately if there
# is an error, instead of just returning the error value. Unfortunately, the
# package managers on both Travis CI and CircleCI install a version of
# Portmidi that has that flag turned on. That means that these tests will
# always time out waiting for user input on those systems.

require "./spec_helper"

describe InputStream do
  it "throws an error given a bad input device id" do
    expect_raises(PortMIDI::InvalidDeviceId, "error opening input device -1") do
      InputStream.open(-1)
    end
  end
end

describe OutputStream do
  it "throws an error given a bad output device id" do
    expect_raises(PortMIDI::InvalidDeviceId, "error opening output device -1") do
      OutputStream.open(-1)
    end
  end
end

describe SimpleMIDIDevice do
  it ".open raises an error given a bad device id" do
    expect_raises(PortMIDI::InvalidDeviceId, "error opening input device -1") do
      SimpleMIDIDevice.open(-1, -1)
    end
  end
end
