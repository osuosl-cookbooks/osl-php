directory '/var/www/phphelpertest' do
  recursive true
end

file '/var/www/phphelpertest/test_file.php' do
  content 'test for me!'
end

directory '/var/www/test_the_second' do
  recursive true
end

file '/var/www/test_the_second/me_too.php' do
  content 'test for me too!'
end
