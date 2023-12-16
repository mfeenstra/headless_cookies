#!/usr/bin/env ruby

## Load cookies and download a remote file à la Wget.
#    We achieve this by using headless Chrome browser and Selenium WebDriver from
#    the command line.  First, navigate to your site and save your session cookies with
#    a browser extension as ./cookies.json.  We'll then load those cookies and spoof the
#    session here.  matt.a.feenstra@gmail.com

require 'selenium-webdriver'
require 'uri'

# for my example, I get this binary to flash an Alienware BIOS flash
@url = "https://dl.dell.com/FOLDER10831114M/1/BIOS_IMG.rcv?" \
       "uid=#{File.read('uid.txt')}fn=BIOS_IMG.rcv"

def get_driver
  begin
    options = Selenium::WebDriver::Options.chrome
    driver = Selenium::WebDriver.for(:chrome, options: @options)
    driver.manage.timeouts.implicit_wait = 500
  rescue => e
    puts "ERROR: #{e.message}"
    exit 1
  end
  driver
end

def load_cookies(filename = 'cookies.json')
  cookies = JSON.parse(File.read(filename))
  sesh_cookies = cookies.map { |e| e.transform_keys(&:to_sym) }
  sesh_cookies.map { |e| e.delete_if { |key| key == :sameSite } }
end

def nav_to(base_url, driver = @driver)
  begin
    driver.get base_url
  rescue => e
    puts "ERROR: nav_to: #{e.message}"
  end
  true
end

### main ###

@driver = get_driver

# base url
uri = URI.parse @url
nav_to(uri.origin)

# load cookies
load_cookies.each do |c|
  @driver.manage.add_cookie(c)
end

# downloads auto-magically, if we sleep..
sleep 2
nav_to @url
sleep 5
@driver.close
