defmodule Bot do

	use Supervisor

	def supervisor do
		children = [
			worker(Abs_GenSrv, [[1,2,3], [name: SimpleQueue]])
		]

		{:ok, pid} = Supervisor.start_link(children, strategy: :one_for_all)
		Supervisor.count_children(pid)
	end

	def telegram_proxy_opt do
		telegram_proxy_host = Application.fetch_env!(:bot, :telegram_proxy_host)
		telegram_proxy_port = Application.fetch_env!(:bot, :telegram_proxy_port)
		telegram_proxy_user = Application.fetch_env!(:bot, :telegram_proxy_user)
		telegram_proxy_pass = Application.fetch_env!(:bot, :telegram_proxy_pass)

		options = [ 
					proxy: {:socks5, telegram_proxy_host, telegram_proxy_port}, 
					socks5_user: telegram_proxy_user,
					socks5_pass: telegram_proxy_pass
				]
	end

	def telegram_pull(pid) do
		{:ok, offset} = Abs_GenSrv.get_key(pid, 'offset') 
		
		HTTPoison.start

		options = telegram_proxy_opt		
		telegram_token = Application.fetch_env!(:bot, :telegram_token)
		url = "https://api.telegram.org/bot#{telegram_token}/getUpdates?offset=#{offset}"
		headers = [{"Content-Type", "application/json"}]

		{:ok, %HTTPoison.Response{status_code: 200, body: body}} = HTTPoison.get(url, %{}, options)
		{:ok, messages_from_users} = Poison.decode(body)

		Enum.map(messages_from_users["result"], fn x-> 
			x_data = if Map.has_key?(x, "callback_query") do			# this is cb
				x["callback_query"]
			else 														# this is message
				x["message"]
			end

			update_id = x["update_id"]
			if update_id > offset do

				chat_id = x_data["from"]["id"]

				if Map.has_key?(x_data, "data")  do			# get cb data
					cb_data = x_data["data"]
					IO.puts("#{cb_data} form #{chat_id}")
				else
					message_text = x_data["text"]

					IO.puts("#{chat_id} say #{message_text}")

					case message_text do
			 			"test" ->
			 				body = "{\"chat_id\":339507845, \"text\":\"pruebax\", \"reply_markup\": {\"inline_keyboard\": [[{\"text\":\"LaResistencia.co\", \"callback_data\": \"CB_DATA\"}]]} }"
			 				url = "https://api.telegram.org/bot#{telegram_token}/sendMessage"
			 				HTTPoison.post "#{url}", body, headers, options

			 				{:ok, %HTTPoison.Response{status_code: 200, body: body}}
			 			_ -> "skip"
			 		end
				end

				Abs_GenSrv.kv(pid, 'offset', update_id)

			end
		end)

		telegram_pull(pid)
	end

	def telegram_init do
		{:ok, pid} = Abs_GenSrv.start_link(%{}, 'general')
		telegram_pull(pid)
	end

	def client do
		Bot.supervisor
		
		Abs_GenSrv.push(SimpleQueue, 4)

		val = Abs_GenSrv.pop(SimpleQueue)
		IO.puts(val)
		
		val = Abs_GenSrv.pop(SimpleQueue)
		IO.puts(val)

		val = Abs_GenSrv.pop(SimpleQueue)
		IO.puts(val)

		val = Abs_GenSrv.pop(SimpleQueue)
		IO.puts(val)

		val = Abs_GenSrv.pop(SimpleQueue)
		IO.puts(val)
	end
end

# после падения супервизорда происходит повторная инициализация из спеки
# и в стеке снова значения 1,2,3 но они уже обработаны
# https://elixirforum.com/t/trying-to-write-a-stateful-worker-process/13497/3