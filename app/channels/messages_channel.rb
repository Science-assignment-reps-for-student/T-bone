class MessagesChannel < ApplicationCable::Channel
  def subscribed
    stream_from 'chat_message_channel'
    ActionCable.server.broadcast('chat_message_channel', message: 'hello world!')
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
  end

  def speak(data)
    ActionCable.server.broadcast('chat_message_channel', message: data)
  end
end
