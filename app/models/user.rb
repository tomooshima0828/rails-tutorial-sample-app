class User < ApplicationRecord
    # トークンは :nameや:emailといった属性のようにデータベースに保存できないので、
    # 仮の属性 :remember_token を作り、トークンをブラウザのcookiesに保存する。 self.remember_token
  attr_accessor :remember_token,
                :activation_token,
                :reset_token
  before_save :downcase_email
  before_create :create_activation_digest
  validates :name,  presence: true, 
                      length: { maximum: 50 }
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
  validates :email, presence: true,
                      length: { maximum: 255 },
                      format: { with:VALID_EMAIL_REGEX },
                      uniqueness: true
  has_secure_password # has_secure_passwordに:password, allow_nil:falseが組み込まれているのでUser.newのときにpasswordは必要
  validates :password, presence: true, length: { minimum: 6 }, allow_nil: true
  def User.digest(string)
    cost = ActiveModel::SecurePassword.min_cost ? BCrypt::Engine::MIN_COST :
                                                  BCrypt::Engine.cost
    BCrypt::Password.create(string, cost: cost)
  end

  # ランダムな文字列を生成する => 
  # ①-a ランダムな文字列を:remember_tokenとしてcookiesに保存する　①-b :user_idも暗号化されてcookiesに保存される
  # ②ランダムな文字列はrememberメソッドで不可逆的にハッシュ化されて、:remember_digestとしてデータベースに保存される
  # ①と②を照合することでsessionが維持される(remember me)
  def User.new_token 
    SecureRandom.urlsafe_base64
  end

  # 永続セッションのためにユーザーをデータベースに記憶する
  def remember
    self.remember_token = User.new_token #セッターメソッドを呼び出すときには必ずselfを付ける
    self.update_attribute(:remember_digest, User.digest(self.remember_token)) #上記以外はselfは省略可能
    # selfを付けた場合 => self.update_attribute(:remember_digest, User.digest(self.remember_token))
    # update_attributeはvalidationを経由せずにデータベース上の属性を更新させる。
    # このrememberメソッドではremember_tokenが生成されてUser.digestでハッシュ化されるだけなのでvalidationは不要。 
  end

  # 渡されたトークンがダイジェストと一致したらtrueを返す
  # def authenticated?(remember_token)
  def authenticated?(attribute, token) # 引数が2つに
    digest = send("#{attribute}_digest")
    return false if digest.nil?
    BCrypt::Password.new(digest).is_password?(token)
  end

  # ユーザーのログイン情報を破棄する
  def forget
    self.update_attribute(:remember_digest, nil)
  end

  def activate
    self.update_attribute(:activated,    true)
    self.update_attribute(:activated_at, Time.zone.now)
  end

  def send_activation_email
    UserMailer.account_activation(self).deliver_now
  end

  def create_reset_digest
    self.reset_token = User.new_token
    self.update_attribute(:reset_digest, User.digest(self.reset_token))
    self.update_attribute(:reset_sent_at, Time.zone.now)
  end

  def send_password_reset_email
    UserMailer.password_reset(self).deliver_now
  end

  def password_reset_expired?
    self.reset_sent_at < 2.hours.ago
  end

  private

    def downcase_email
      self.email = self.email.downcase
    end
    
    def create_activation_digest
      self.activation_token = User.new_token
      self.activation_digest = User.digest(self.activation_token)
    end
end



