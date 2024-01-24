class ChatMessageCreatedJob < ApplicationJob
  queue_as :default


  def perform(chat_message)
    @chat_message = chat_message
    # debugger
    # response = openai_client.chat(
    #   parameters: {
    #     model: "gpt-3.5-turbo",
    #     messages: message,
    #     temperature: 0.9
    #   }
    # )
    response = openai_client.completions(
      engine: "gpt-3.5-turbo-instruct",  # Change the engine based on your needs
      prompt: message,
      temperature: 0.9
    )
    # answer = response.dig("choices", 0, "message", "content")
    answer = response.dig("choices", 0, "text")
    puts "Got Response: #{answer}"

    system_message = ChatMessage.create!(
      role: "system",
      content: answer,
      chat: @chat_message.chat
    )

    Turbo::StreamsChannel.broadcast_append_to(
      "chat_messages_#{chat_message.chat.id}",
      target:  "chat_messages_#{chat_message.chat.id}",
      partial: "chat_messages/chat_message",
      locals: { chat_messages: system_message }
    )
  end

  private

  def message
    messages = @chat_message.chat.chat_messages.order(created_at: :asc).map do |m|
      "#{m.role}: #{m.content}"
    end
    messages.join("\n")
  end

  def openai_client

    OpenAI::Client.new(api_key: "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")
    # OpenAI::Client.new(api_key: "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")
  end
end

