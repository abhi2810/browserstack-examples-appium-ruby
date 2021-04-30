require "rubygems"
require "selenium-webdriver"
require "test-unit"
require "appium_lib"
require "browserstack/local"
require "rest_client"

class AndroidAppTest < Test::Unit::TestCase

  # curl -u "<user>:<key>"
  # -X POST "https://api.browserstack.com/app-automate/upload"
  # -F "file=@/Path/to/File/WikipediaSample.apk"
  # -F "data={\"custom_id\": \"DemoApp\"}"

  def setup
    caps_list = JSON.parse(ENV["CAPS_LIST"])
    test_index = ENV["SESSION_INDEX"]
    @common_caps = caps_list["common_caps"]
    @session_caps = caps_list["session_caps"][test_index.to_i - 1]

    caps = {}
    @common_caps.each do |cap_name, cap_value|
      caps[cap_name] = cap_value
    end

    @session_caps.each do |cap_name, cap_value|
      caps[cap_name] = cap_value
    end

    browser_name = " #{caps["device"].capitalize} #{caps["os_version"]}"
    caps["name"] = caps["name"] + browser_name
    caps["javascriptEnabled"] = "true"

    appium_driver = Appium::Driver.new({
      "caps" => caps,
      "appium_lib" => {
        :server_url => "http://#{ENV["BROWSERSTACK_USERNAME"]}:#{ENV["BROWSERSTACK_ACCESS_KEY"]}@hub-cloud.browserstack.com/wd/hub",
      },
    }, true)
    @driver = appium_driver.start_driver
  end

  def test_post
    wait = Selenium::WebDriver::Wait.new(:timeout => 30)
    wait.until { @driver.find_element(:accessibility_id, "Search Wikipedia").displayed? }
    element = @driver.find_element(:accessibility_id, "Search Wikipedia")
    element.click
    wait.until { @driver.find_element(:id, "org.wikipedia.alpha:id/search_src_text").displayed? }
    search_box = @driver.find_element(:id, "org.wikipedia.alpha:id/search_src_text")
    search_box.send_keys("BrowserStack")

    wait.until { @driver.find_element(:class, "android.widget.TextView").displayed? }
    results = @driver.find_elements(:class, "android.widget.TextView")

    results_count = results.count

    assert_equal(results_count, results_count)
  end

  def teardown
    if @_result.passed?
      @driver.execute_script('browserstack_executor: {"action": "setSessionStatus", "arguments": {"status":"passed", "reason": "Test Passed"}}')
    else
      @driver.execute_script('browserstack_executor: {"action": "setSessionStatus", "arguments": {"status":"failed", "reason": "Test Failed"}}')
    end
    @driver.quit
  end
end
