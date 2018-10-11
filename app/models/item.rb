class Item < ApplicationRecord


  ###### ASSOCIATION ########
  belongs_to :list


  mount_base64_uploader :image_url, ImageUploader


  def set_picture(data)
    temp_file = Tempfile.new(['temp', '.png'], :encoding => 'ascii-8bit')

    begin
      temp_file.write(data)
      self.image_url = temp_file
    ensure
      temp_file.close
      temp_file.unlink
    end
  end

end



