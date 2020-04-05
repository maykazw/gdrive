class IndexController < ApplicationController
  def index
    @session = GoogleDrive::Session.from_service_account_key(ENV['CONFIGJSON'])
  end

  def replace
    directory_name = ENV['FOLDERNAME']
    Dir.mkdir(directory_name) unless File.exists?(directory_name)
    @file_url = Rails.root.join('files',ENV['FILE_DOWNLOADED_NAME']).to_s
    @session = GoogleDrive::Session.from_service_account_key(ENV['CONFIGJSON'])
    file = @session.file_by_id(ENV['FILE_ID'])
    file.download_to_file(@file_url)
    require 'omnidocx'
    @file_url2 = Rails.root.join('files',ENV['FILE_TEMP_NAME'])
    FileUtils.touch @file_url2
    replacement_hash = { ENV['WORD_TO_CHANGE'] => ENV['WORD_CHANGED']}
    Omnidocx::Docx.replace_doc_content(replacement_hash, @file_url, @file_url2)
    file.update_from_file(@file_url2)
  end

  def create
    directory_name = ENV['FOLDERNAME']
    Dir.mkdir(directory_name) unless File.exists?(directory_name)
    file_url = Rails.root.join('files',ENV['FILE_DOWNLOADED_NAME']).to_s
    FileUtils.touch file_url
    Caracal::Document.save file_url do |docx|
      # page 1
      docx.h1 'Page 1 Header'
      docx.hr
      docx.p
      docx.h2 'Section 1'
      docx.p  ' Nulla eu leo nisi. Nunc lacus justo, aliquet imperdiet risus interdum, feugiat ultrices tortor. Fusce id hendrerit sem. Duis non accumsan turpis. Aliquam pretium vel nunc in ultrices. Donec pretium turpis purus, at tincidunt nunc ultricies id. Integer lorem velit, pharetra nec iaculis a, ultrices non nulla. Duis sit amet purus metus. Suspendisse a elementum sapien. In hac habitasse platea dictumst. Ut accumsan, ex eu feugiat varius, lorem nulla tempus ex, eget consequat nibh enim eu ante. Nulla facilisi. Nullam sollicitudin ipsum at venenatis aliquet. '
            # page 2
      docx.page
      docx.h1 'Page 2 Header'
      docx.hr
      docx.p
      docx.h2 'Section 2'
      docx.p  'Nam et accumsan accumsan Nam et accumsan accumsan Nam et accumsan accumsan Nam et accumsan accumsan Nam et accumsan accumsan Nam et accumsan accumsan Nam et accumsan accumsan Nam et accumsan accumsan Nam et accumsan accumsan Nam et accumsan accumsan '
      docx.ul do
        li 'Item 1'
        li 'Item 2'
      end
      docx.p ' '
    end
    @session = GoogleDrive::Session.from_service_account_key(ENV['CONFIGJSON'])
    @session.upload_from_file(Rails.root.join('files',ENV['FILE_DOWNLOADED_NAME']).to_s, 'example.docx', convert: false)
  end
end
