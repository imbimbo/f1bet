class MessagesController < ApplicationController
  before_action :set_chat

  def create
    @message = @chat.messages.build(
      content: params[:message][:content],
      file: params[:message][:file],
      user: current_user,
      role: :user
    )

    if @message.save
      respond_to do |format|
        format.turbo_stream
        format.html { redirect_to chat_path(@chat) }
      end
    else
      head :unprocessable_entity
    end
  end

  def destroy
    @message = @chat.messages.find(params[:id])
    return head :forbidden if @message.user != current_user

    @message.destroy

    respond_to do |format|
      format.turbo_stream
      format.html { redirect_to chat_path(@chat) }
    end
  end

  private

  def set_chat
    @chat = Chat.find(params[:chat_id])
  end
end
