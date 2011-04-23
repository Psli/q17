class Notification < ActiveRecord::Base
  
 # field :has_read, :type => Boolean, :default => false
 # field :target_id
 # field :action
  
  belongs_to :log
  belongs_to :user
  
  scope :unread, where(:has_read => false) 
  
  after_create :publish_to_owner
  
  def publish_to_owner
    return if self.user.nil?
    Rails.logger.info "publish_to_owner"
    load_zomet_config
    pub_to_browser({
      :channel => "/notifications/#{self.user.slug}", 
      :data_type => "text", 
      :data => "\"Hello from Ruby #{Time.now.strftime("%H:%M:%S")}\""
    })
  end
end
