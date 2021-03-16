class UserMailer < ApplicationMailer

  def account_activation(user)
    @user = user
    mail to: user.email, # メールの送付先
         subject: "Account activation" # subjectは固定
    # => return: mail object (text/html)
  end

  def password_reset
    @greeting = "Hi"

    mail to: "to@example.org"
  end
end
