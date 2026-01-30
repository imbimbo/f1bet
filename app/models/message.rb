
class Message < ApplicationRecord
  include ActionView::RecordIdentifier

  belongs_to :chat
  belongs_to :user, optional: true

  has_one_attached :file

  enum role: { user: 0, assistant: 1 }

  validates :content, presence: true, unless: -> { file.attached? }

  # after_create_commit :broadcast_append
  # after_destroy_commit :broadcast_remove

  def mine?(user)
    user.present? && user.id == user_id
  end


  private

  # def broadcast_append
  #   broadcast_append_to(
  #     chat,
  #     target: "messages",
  #     partial: "messages/message",
  #     locals: {
  #       message: self,
  #       mine: false
  #     }
  #   )
  # end

  # def broadcast_remove
  #   broadcast_remove_to(chat, target: dom_id(self))
  # end

end
