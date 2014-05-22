#!/usr/bin/env ruby


# Builds a dynamic base theme. Questions are asked and stored as variables to be
# used for search and replace, deleting/renaming files and more. Unless you would like
# to add new features to Theme Builder only modify the theme_questions method.
#
# TODO: Look into YAML for questions in separate file and make this class to parse it instead of using Procs
class CommandLineInterface

  # This is where questions for the theme go. Group question and methods used inside of an procedure
  # and call where appropriate. Methods used for each question should always be called at the end of
  # the proc. Questions that call the write_replace method directly should come after other question.
  def theme_questions

    ## Welcome Message
    welcome = Proc.new do
      print "\n\nTo view the themes readme file please type "
      print 'help'.magenta + ' or ' + 'h'.magenta + '. ' # Make keywords a different color
      print 'To continue building the theme type any key or hit enter.'
      answer = gets.chomp.strip.downcase
      Builder.readme_open(answer)
    end

    ## VIP
    vip = Proc.new do
      puts "\nWill this theme need WordPress VIP theme support?"
      answer = gets.chomp.strip.downcase
      check_answer(answer, vip) # Default checks for yes or no
      Builder.tag_replace_delete('VIP', answer)
    end

    ## Language Support
    lang_support = Proc.new do
      puts "\nWill this theme need language support?"
      answer = gets.chomp.strip.downcase
      check_answer(answer, lang_support) # Default checks for yes or no
      Builder.file_or_dir_delete('languages', answer)
      Builder.tag_replace_delete('LANG', answer)
    end

    ## Custom Post Types
    custom_post_types = Proc.new do
      puts "\nWill this theme need custom post type support?"
      answer = gets.chomp.strip.downcase
      check_answer(answer, custom_post_types) # Default checks for yes or no

      if answer == 'yes' || answer == 'y'
        Builder.tag_replace_delete('CUSTOM-POSTS', answer, true)
        Builder.custom_post_types_create
      else
        FileUtils.rm_rf('extensions/custom-post-types')
        Builder.tag_replace_delete('CUSTOM-POSTS', answer)
      end
    end

    ## Compass Support (only called from sass procedure)
    compass = Proc.new do
      puts "\nWould you like to use Compass with this theme?"
      answer = gets.chomp.strip.downcase
      check_answer(answer, compass) # Default checks for yes or no
      Builder.tag_replace_delete('COMPASS', answer)
      Builder.tag_replace_delete('GULPCOMPASS', answer, true)
      Builder.tag_replace_delete('GULPNONCOMPASS', answer)
      Builder.file_or_dir_delete('config.rb', answer)
    end

    ## SASS Support
    sass = Proc.new do
      puts "\nWould you like to use SASS with this theme?"
      answer = gets.chomp.strip.downcase
      check_answer(answer, sass) # Default checks for yes or no
      Builder.file_or_dir_delete('sass', answer)
      Builder.tag_replace_delete('SASSGULP', answer, true)

      if answer == 'y' || answer == 'yes'
        compass.call
      else
        File.open('css/styles.css', 'w') { |file| file.truncate(0) } # Empty contents of css file
      end
    end

    ## Gulp Support
    gulp = Proc.new do
      puts "\nWould you like to use Gulp with this theme?"
      puts "(Gulp allows automating tasks like autoprefixing, concatenation, etc..)".magenta
      answer = gets.chomp.strip.downcase
      check_answer(answer, gulp) # Default checks for yes or no
      Builder.file_or_dir_delete('gulpfile.js', answer)
      Builder.file_or_dir_delete('package.json', answer)
      Builder.tag_replace_delete('GULP', answer, true)
      Builder.tag_replace_delete('NONGULP', answer)

      if answer == 'y' || answer == 'yes'
        # puts `npm install`
        puts "\n\nIn order to run Gulp you have to have npm installed.".magenta
        puts "Please refer to the gulpfile.js file for more information.".magenta
        puts "To run Gulp open a new Terminal window and cd into the themes root directory".magenta
        puts "Run npm install and then type gulp.".magenta
      end
    end

    ## Theme Name
    theme_name = Proc.new do
      puts "\nWhat is the name of your new theme?"
      answer = gets.chomp.gsub('*/', '') # Don't close PHP comments
      find_replace_var = {:replacement=>answer, :original=>'{%= title %}'}
      find_replace_var_capitalize = {:replacement=>answer.capitalize, :original=>'{%= title_capitalize %}'}

      Builder.write_replace(find_replace_var)
      Builder.write_replace(find_replace_var_capitalize)
    end

    ## Author
    author = Proc.new do
      puts "\nWhat is the theme author's name?"
      answer = gets.chomp.gsub('*/', '') # Don't close PHP comments
      find_replace_var = {:replacement=>answer, :original=>'{%= author %}'}
      Builder.write_replace(find_replace_var)
    end

    ## Author URI
    author_uri = Proc.new do
      puts "\nWhat is the theme authors URL?"
      puts "(Must start with http://, https:// or www)".magenta
      answer = gets.chomp.gsub('*/', '') # Don't close PHP comments
      url_regex = /((([A-Za-z]{3,9}:(?:\/\/)?)(?:[\-;:&=\+\$,\w]+@)?[A-Za-z0-9\.\-]+|(?:www\.|[\-;:&=\+\$,\w]+@)[A-Za-z0-9\.\-]+)((?:\/[\+~%\/\.\w\-_]*)?\??(?:[\-\+=&;%@\.\w_]*)#?(?:[\.\!\/\\\w]*))?)/
      check_answer(answer, author_uri, url_regex)
      find_replace_var = {:replacement=>answer, :original=>'{%= author_uri %}'}
      Builder.write_replace(find_replace_var)
    end

    ## Theme URI
    theme_uri = Proc.new do
      puts "\nWhat is the theme URL?"
      puts "(Must start with http://, https:// or www)".magenta
      answer = gets.chomp.gsub('*/', '') # Don't close PHP comments
      url_regex = /((([A-Za-z]{3,9}:(?:\/\/)?)(?:[\-;:&=\+\$,\w]+@)?[A-Za-z0-9\.\-]+|(?:www\.|[\-;:&=\+\$,\w]+@)[A-Za-z0-9\.\-]+)((?:\/[\+~%\/\.\w\-_]*)?\??(?:[\-\+=&;%@\.\w_]*)#?(?:[\.\!\/\\\w]*))?)/
      check_answer(answer, theme_uri, url_regex)
      find_replace_var = {:replacement=>answer, :original=>'{%= theme_uri %}'}
      Builder.write_replace(find_replace_var)
    end

    ## Project Prefix
    prefix = Proc.new do
      print "\nWhat should the prefix for your theme be? "
      puts "\n(At least three characters, first and last characters letters only, letters and _'s for the rest.)".magenta
      answer = gets.chomp.strip.downcase
      check_answer(answer, prefix, /^[a-z][a-z_]+[a-z]$/) # first + last character a-z rest a-z + _'s
      find_replace_var = {:replacement=>answer, :original=>'{%= prefix %}'}
      find_replace_var_capitalize = {:replacement=>answer.capitalize, :original=>'{%= prefix_capitalize %}'} # for classes

      Builder.write_replace(find_replace_var)
      Builder.write_replace(find_replace_var_capitalize)
    end

    ## Theme Description
    description = Proc.new do
      puts "\nPlease list your themes description"
      answer = gets.chomp.gsub('*/', '') # Don't close PHP comments
      find_replace_var = {:replacement=>answer, :original=>'{%= description %}'}
      Builder.write_replace(find_replace_var)
    end

    ## Change Answers
    change_answers = Proc.new do
      puts "\nDo you need to change any information?"
      answer = gets.chomp.downcase
      check_answer(answer, change_answers) # Default checks for yes or no
      reset_answers?(answer)
    end

    # Load up all questions that don't use write_replace method directly
    welcome.call
    vip.call
    lang_support.call
    custom_post_types.call
    sass.call
    gulp.call

    # Questions using write_replace method should come after this
    theme_name.call
    theme_uri.call
    author.call
    author_uri.call
    prefix.call
    description.call

    # Ask if you need to reset any answers
    change_answers.call
  end


  # Check if program is interrupted by control+C
  # run git reset --hard to remove changes
  # run git clean -f to remove any untracked files
  def intercept
    trap('INT') do
      puts "\n\n"
      puts `git reset --hard`
      puts `git clean -f`
      STDERR.puts "\n\nTheme generation exited and theme has been reset to its original state.".red
      exit
    end
  end

  # Methods after this point are private
  private


  # Method used to check if answer meets criteria
  def check_answer(answer, question, only_contain = 'default')
    if only_contain == 'default'
      if answer != 'yes' && answer != 'y' && answer != 'no' && answer != 'n'
        puts "\nPlease try again and type either yes, y, no, or n".red
        question.call
      end
    else
      # Test answer vs passed in regex
      if answer !~ only_contain
        puts "\nPlease try again".red
        question.call
      end
    end
  end

  # Ask if needs to change any information. If answered yes git reset and call
  # questions method again. If no changes need to be made delete this file
  def reset_answers?(answer)
    if answer == 'yes' || answer == 'y'
      puts `git reset --hard`
      theme_questions
    elsif answer == 'no' || answer == 'n'
      File.delete 'builder.rb'
      explosion
    end
  end


  # Visually show the file self destructed
  def explosion
    puts '



                _.-^^---....,,--
            _--                  --_
           <                        >)
           |                         |
            \._                   _./
               ```--. . , ; .--"""
                     | |   |
                  .-=||  | |=-.
                  `-=#$%&%$#=-"
                     | ;  :|
            _____.,-#%&$@%#&#~,._____
        '
    puts "\n\n\nThis file has self destructed"
    puts "\nEnjoy your theme!"
  end
end

# Various methods for search/replace, deleting/renaming files and more
#
# TODO: Move the module to a separate file or package as a gem
module Builder
  class << self

    require 'fileutils'

    # Used to either keep text between tags or delete it from the template.
    # Tags in theme files are {{{foo}}} {{{/foo}}}
    #
    # TODO: Find a better way to inverse code
    def tag_replace_delete(tag_var, answer, inverse_delete = false)
      tag_open = '{{{' + tag_var + '}}}'
      tag_close = '{{{/' + tag_var + '}}}'

      if inverse_delete == true
        if answer == 'yes' || answer == 'y'
          delete_open = {:original=>tag_open, :replacement=>''}
          delete_close = {:original=>tag_close, :replacement=>''}
          write_replace(delete_open)
          write_replace(delete_close)
        else
          between = tag_open + '[\s\S]*?' + tag_close
          reg_between = Regexp.new(between, Regexp::IGNORECASE);
          find_replace_var = {:original=>reg_between, :replacement=>''}
          write_replace(find_replace_var)
        end
      else
        if answer == 'no' || answer == 'n'
          delete_open = {:original=>tag_open, :replacement=>''}
          delete_close = {:original=>tag_close, :replacement=>''}
          write_replace(delete_open)
          write_replace(delete_close)
        else
          between = tag_open + '[\s\S]*?' + tag_close
          reg_between = Regexp.new(between, Regexp::IGNORECASE);
          find_replace_var = {:original=>reg_between, :replacement=>''}
          write_replace(find_replace_var)
        end
      end
    end


    # Loop through every file and perform search and replace
    def write_replace(find_replace_var, skip = 'none')

      # First set the file locations only if the correct extension
      files = Dir.glob('**/**.{php,css,txt,scss,js,json}')

      files.each do |file_name|

        # Skip if file passed into method
        # TODO: Find more efficient way to skip the node_modules folder

        if skip != 'none'
          next if file_name == skip
        end

        next if file_name =~ /node_modules/i

        text = File.read(file_name)
        replace = text.gsub(find_replace_var[:original], find_replace_var[:replacement])
        File.open(file_name, 'w') { |file| file.puts replace }

        # TODO: Find way of only showing files that were updated
        puts "Updating #{file_name}"
      end
    end


    # Method that loads readme file in the commandline
    def readme_open(answer)
      if answer == 'help' || answer == 'h'
        puts "\n\n\n"
        readme = File.open('README.md', 'r')
        readme.each_line do |line|
          puts line.cyan
        end
        puts "\nPress any key to continue"
        gets
      end
    end


    # Deletes a file or directory depending on answer.
    def file_or_dir_delete(file_or_directory, answer = "no")
      if answer == 'no' || answer == 'n'
        if File.directory? file_or_directory
          FileUtils.rm_rf(file_or_directory)
        else
          File.delete file_or_directory
        end
        puts "\n#{file_or_directory} deleted".red
      elsif answer == 'yes' || answer == 'y'
        puts "\n#{file_or_directory} kept".cyan
      end
    end


    # Builds file includes string and calls write_replace method
    def file_includes(files_array, tag_to_replace)
      tag_replacement = ''

      files_array.each_with_index do |file, index|

        # Move to new line if not the first file
        if index == 0
          file_place = "require get_template_directory() . '/" + file + "';"
        else
          file_place = "\nrequire get_template_directory() . '/" + file + "';"
        end

        tag_replacement = tag_replacement + file_place
      end

      # Put includes into functions.php
      find_replace_var = {:replacement=>tag_replacement, :original=>tag_to_replace}
      write_replace(find_replace_var)
    end


    # Creates custom post types if needed by asking how many and then asking for a name. If no
    # custom post type is needed the custom post type folder is deleted. This method needs lots of refactoring.
    #
    # TODO: Make this not specific to CPT's but to files that can be created more than once
    def custom_post_types_create
      puts "\nHow many custom post types do you need?"
      amount = gets.chomp.to_i

      if amount > 0

        original_file = 'extensions/custom-post-types/custom-post-type.php'
        files_array = Array.new
        index = 0

        # Loop through number of custom post types specified and create them
        amount.times do
          index = index + 1
          puts "\nWhat should the post type #{index} be named?"
          puts "(At least three characters, first and last characters letters only, letters and _'s for the rest.)".magenta
          answer = gets.chomp.strip.downcase

          # TODO: Make use check_answer method at some point
          until answer =~ /^[a-z][a-z_]+[a-z]$/
            puts "\nPlease try again".red
            puts "\nWhat should the post type #{index} be named?"
            puts "\n(At least three characters, first and last characters letters only, letters and _'s for the rest.)".magenta
            answer = gets.chomp.strip.downcase
          end

          new_file = 'extensions/custom-post-types/' + answer.gsub(' ', '-') + '-post-type-class.php'

          # Make sure not duplicate answer
          files_array.each do |file|
            if new_file == file
              until new_file != file
                puts "\nPost type name already used".red
                puts "\nWhat should the post type #{index} be named?"
                puts "\n(At least three characters, first and last characters letters only, letters and _'s for the rest.)".magenta
                answer = gets.chomp.strip.downcase

                new_file = 'extensions/custom-post-types/' + answer.gsub(' ', '-') + '-post-type-class.php'
              end
            end
          end

          # Push files into files array for includes later
          FileUtils.cp original_file, new_file
          files_array.push(new_file)

          # Find and replace variables
          find_replace_var = {:replacement=>answer, :original=>'{%= post_type_name %}'}
          find_replace_var_capitalize = {:replacement=>answer.capitalize, :original=>'{%= post_type_name_capitalize %}'}

          write_replace(find_replace_var, original_file)
          write_replace(find_replace_var_capitalize, original_file)
          puts "\nCreated #{new_file}"
        end

        # Delete original file and add includes into functions.php
        File.delete original_file
        file_includes(files_array, '{%= post_type_include %}')
      end
    end
  end
end


# Extend string class to add colors for strings
class String
  def red;         "\033[31m#{self}\033[0m" end
  def cyan;        "\033[36m#{self}\033[0m" end
  def magenta;     "\033[35m#{self}\033[0m" end
end


puts '

  ____    _    _   _____   _        _____    ______   _____
 |  _ \  | |  | | |_   _| | |      |  __ \  |  ____| |  __ \
 | |_) | | |  | |   | |   | |      | |  | | | |__    | |__) |
 |  _ <  | |  | |   | |   | |      | |  | | |  __|   |  _  /
 | |_) | | |__| |  _| |_  | |____  | |__| | | |____  | | \ \
 |____/   \____/  |_____| |______| |_____/  |______| |_|  \_\

                                 ___________________________
                                |                           |
                                |  DYNAMIC THEME GENERATOR  |
                                |___________________________|

                                @author Nick Blanchard

 '


builder = CommandLineInterface.new
builder.intercept
builder.theme_questions
