class User < ApplicationRecord
    # トークンは :nameや:emailといった属性のようにデータベースに保存できないので、
    # 仮の属性 :remember_token を作り、トークンをブラウザのcookiesに保存する。 self.remember_token
  attr_accessor :remember_token
  before_save { self.email = self.email.downcase }
  validates :name,  presence: true, 
                      length: { maximum: 50 }
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
  validates :email, presence: true,
                      length: { maximum: 255 },
                      format: { with:VALID_EMAIL_REGEX },
                      uniqueness: true
  has_secure_password
  validates :password, presence: true, length: { minimum: 6 }

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
    update_attribute(:remember_digest, User.digest(remember_token)) #上記以外はselfは省略可能
    # selfを付けた場合 => self.update_attribute(:remember_digest, User.digest(self.remember_token))
    # update_attributeはvalidationを経由せずにデータベース上の属性を更新させる。
    # このrememberメソッドではremember_tokenが生成されてUser.digestでハッシュ化されるだけなのでvalidationは不要。 
  end

  # 渡されたトークンがダイジェストと一致したらtrueを返す
  def authenticated?(remember_token)
    return false if remember_digest.nil?
    BCrypt::Password.new(remember_digest).is_password?(remember_token)
  end

  # ユーザーのログイン情報を破棄する
  def forget
    self.update_attribute(:remember_digest, nil)
  end
end



