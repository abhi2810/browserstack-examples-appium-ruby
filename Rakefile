# Prep ENV

require "json"
require "rest-client"
require "jsonpath"

if ENV["BROWSERSTACK_USERNAME"].nil? or ENV["BROWSERSTACK_ACCESS_KEY"].nil?
  abort "Please initialize environment variables BROWSERSTACK_USERNAME and BROWSERSTACK_ACCESS_KEY with your BrowserStack account username and access key, before running tests"
end

def read_test_config(test_type)
  if ENV["CAPS_LIST"].nil? or ENV["CAPS_LIST"].empty?
    caps_file_content = File.read("caps.json")
    caps_file_content = caps_file_content.gsub(/\,(?=\s*?[\}\]])/,'')
    tests = JSON.parse(caps_file_content)["tests"]
    test_type_path = JsonPath.new("$.[?(@.test_type == #{test_type})]")
    test_type_path.on(tests)[0]
  else
    caps_list_context = ENV["CAPS_LIST"].gsub("\\", "")
    caps_list_context = caps_list_context.gsub(/\,(?=\s*?[\}\]])/,'')
    JSON.parse(caps_list_context)
  end
end

# App Automate - Android Appium Test
def run_appium_test(caps_list, session_index)
  caps_list = caps_list.to_json.gsub("\"", "\\\"")
  command = "CAPS_LIST=\"#{caps_list}\" SESSION_INDEX=#{session_index} ruby appium.rb"
  puts command
  system command
end

if (ARGV[0] == "appium")
  puts "Checking for uploaded apps..."
  prev_uploads = RestClient.get "https://#{ENV["BROWSERSTACK_USERNAME"]}:#{ENV["BROWSERSTACK_ACCESS_KEY"]}@api.browserstack.com/app-automate/recent_apps/DemoApp"
  prev_uploads = JSON.parse(prev_uploads)

  if prev_uploads.class != Array || prev_uploads.empty?
    puts "No previous apps found. Uploading app..."
    puts RestClient.post(
      "https://#{ENV["BROWSERSTACK_USERNAME"]}:#{ENV["BROWSERSTACK_ACCESS_KEY"]}@api.browserstack.com/app-automate/upload",
      file: File.new("./WikipediaSample.apk", "rb"),
      data: { "custom_id": "DemoApp" }.to_json,
    )
  else
    puts "Using Previously Uploaded App:\n" + prev_uploads.last.to_s
  end
  caps_list = read_test_config("appium")
  session_specific_caps = caps_list["session_caps"]
  appium_tests = []
  session_specific_caps.each_with_index do |session, i|
    eval "appium_tests << :appium_tests_#{i}"
    eval "task :appium_tests_#{i} do run_appium_test(#{caps_list}, #{i}) end"
  end
end

multitask appium: appium_tests
