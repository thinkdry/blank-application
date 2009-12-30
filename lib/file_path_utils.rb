require 'fileutils'

# Load Attachments to Fixtures
def file_path_import(params)
    raise unless params[:model]
    raise unless params[:id]
    raise unless params[:file_name]
    src = File.join(RAILS_ROOT, 'test', 'fixtures', 'uploaded_files', params[:model].to_s, 'original',params[:file_name].to_s)
    dst = File.join(RAILS_ROOT, 'public','uploaded_files', params[:model].to_s, params[:id].to_s)
    FileUtils.ln_s(src, dst,:force => true) unless File.exists?(dst)
    params[:file_name]
end
