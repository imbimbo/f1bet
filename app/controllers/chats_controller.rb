class ChatsController < ApplicationController

  def show
    @chat = Chat.find(params[:id])
    @messages = @chat.messages.includes(:user)

    @messages_by_date = @chat.messages
                      .includes(:user)
                      .order(:created_at)
                      .group_by { |m| m.created_at.to_date }

  end

end
