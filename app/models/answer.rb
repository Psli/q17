class Answer < ActiveRecord::Base
  include BaseModel

  # 投票对应的分数
 # voteable self, :up => +1, :down => -1

  #field :body
  #field :comments_count, :type => Integer, :default => 0

  belongs_to :ask, :inverse_of => :answers, :counter_cache => true
  belongs_to :user, :inverse_of => :answers, :counter_cache => true
  has_many :logs, :class_name => "Log", :foreign_key => "target_id"
  
  #field :spams_count, :type => Integer, :default => 0
  #field :spam_voter_ids, :type => Array, :default => []
  
  has_many :comments, :conditions => {:commentable_type => "Answer"}, :foreign_key => "commentable_id", :class_name => "Comment"
  
  validates_presence_of :user_id, :body
  validates_uniqueness_of :user_id, :scope => [:ask_id]

  # 敏感词验证
  before_validation :check_spam_words
  def check_spam_words
    if self.spam?("body")
      return false
    end
  end

  after_create :mail_deliver_new_answer
  def mail_deliver_new_answer
    UserMailer.new_answer_to_followers(self.id)
  end
  
  def chomp_body
    chomped = self.body
    while chomped =~ /<div><br><\/div>$/i
      chomped = chomped.gsub(/<div><br><\/div>$/i, "")
    end
    return chomped
  end

  # 没有帮助
  def spam(voter_id,size = 1)
    self.spams_count ||= 0
    self.spam_voter_ids ||= []
    # 限制 spam ,一人一次
    return self.spams_count if self.spam_voter_ids.index(voter_id)
    self.spams_count += size
    self.spam_voter_ids << voter_id
    self.save()
    return self.spams_count
  end

  after_create :save_to_ask_and_update_answered_at
  before_update :log_update
  
  def log_update
    insert_action_log("EDIT") if self.body_changed?
  end
  
  def save_to_ask_and_update_answered_at
    self.ask.update_attributes({:answered_at => self.created_at, 
                               :last_answer_id => self.id,
                               :last_answer_user_id => self.user_id, 
                               :current_user_id => self.user_id })
  
    # 回答默认关注问题
    self.user.follow_ask(self.ask) if !self.user.ask_followed?(self.ask)
    
    # 保存用户回答过的问题列表
    self.user.answered_asks << self.ask
    insert_action_log("NEW")
  end
  
  def votes_count
    return up_votes_count + down_votes_count
  end
  
  protected
  
    def insert_action_log(action)
      begin
        log = AnswerLog.new
        log.user_id = self.user_id
        log.title = self.body
        log.answer = self
        log.target_id = self.id
        log.target_attr = self.body_changed? ? "BODY" : "" if action == "EDIT"
        log.action = action
        log.target_parent_id = self.ask_id
        log.target_parent_title = self.ask.title
        log.diff = ""
        log.save
      rescue Exception => e
        
      end
      
    end
  
end

# == Schema Information
#
# Table name: answers
#
#  id               :integer(4)      not null, primary key
#  body             :text
#  comments_count   :integer(4)      default(0)
#  spams_count      :integer(4)      default(0)
#  spam_voter_ids   :integer(4)
#  up_votes_count   :integer(4)      default(0)
#  down_votes_count :integer(4)      default(0)
#  ask_id           :integer(4)
#  user_id          :integer(4)
#  created_at       :datetime
#  updated_at       :datetime
#

