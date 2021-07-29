module Danger
  # This is your plugin class. Any attributes or methods you expose here will
  # be available from within your Dangerfile.
  #
  # To be published on the Danger plugins site, you will need to have
  # the public interface documented. Danger uses [YARD](http://yardoc.org/)
  # for generating documentation from your plugin source, and you can verify
  # by running `danger plugins lint` or `bundle exec rake spec`.
  #
  # You should replace these comments with a public description of your library.
  #
  # @example Ensure people are well warned about merging on Mondays
  #
  #          my_plugin.warn_on_mondays
  #
  # @see  Stanislav Katkov/danger-yamlint
  # @tags monday, weekends, time, rattata
  #
  class DangerYamlint < Plugin
    def lint
      broken_yaml = {}

      changed_files.each do |file|
        next unless File.readable?(file)
        next unless (file.end_with?('.yaml') || file.end_with?('.yml'))

        begin
          # Detect fixtures, they could contain ERB code.
          if file.include?('/fixtures/')
            YAML.load(ERB.new(File.read(file)).result)
          else
            YAML.load_file file
          end
        rescue StandardError => e
          broken_yaml.merge!({"#{file}" => e.message})
        end
      end

      unless broken_yaml.empty?
        fail("YAML formatting is not valid for these files:
              #{broken_yaml.map { |file, msg| "**#{file}**: #{msg}" }.join('<br/>')}
        ")
      end
    end

    private

    def changed_files
      (git.modified_files + git.added_files)
    end
  end
end
