require 'fileutils'

def file_path_import(params)
    raise unless params[:model]
    raise unless params[:id]
    raise unless params[:file_path]
    
    src = File.join(RAILS_ROOT, 'test', 'fixtures', 'file_path', params[:model].to_s, params[:file_path].to_s)
    dst = File.join(RAILS_ROOT, 'public', params[:model].to_s, 'file_path', params[:id].to_s)
    
    FileUtils.ln_s(src, dst) unless File.exists?(dst)
    params[:file_path]
end