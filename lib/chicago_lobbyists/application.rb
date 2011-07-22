module ChicagoLobbyists
  class Application < Sinatra::Base
    configure do
      database_url = ENV["DATABASE_URL"] || "postgres://localhost/chicago_hackathon"
      DataMapper::Logger.new($stdout, :debug)
      DataMapper.setup(:default, database_url)
      DataMapper.finalize
    end
    
    helpers do
      def lobbyists_count
        Lobbyist.count
      end

      def firms_count
        Firm.count
      end

      def actions_count
        Action.count
      end

      def clients_count
        Client.count
      end

      def cl_erb(template)
        erb template.to_sym
      end
      
      def current_menu
        @current_menu
      end
      
      def current_menu_class(menu_name)
        return "current" if current_menu == menu_name
      end
      
      def total_paid
        Compensation.sum(:compensation)
      end
      
      def number_to_currency(number)
        decimal_part = number.to_f % 1
        decimal_part_string = ("%.2f" % decimal_part)[1..-1]
        
        integer_part = number.to_i
        integer_part_string = integer_part.to_s.reverse.gsub(/(\d{3}(?=(\d)))/, "\\1,").reverse
        
        "$#{integer_part_string}#{decimal_part_string}"
      end
    end

    def pagination_options_from params={}
      { :limit => :size, :offset => :page }.inject({}) do |memo, hash|
        memo[hash.first] = params[hash.last] || send(hash.last)
      end
    end

    def size
      20
    end

    def page
      0
    end

    get "/" do
      @current_menu = "home"
      @highest_paid_lobbyists = Compensation.group_lobbyist_compensations
      @highest_paid_firms     = Compensation.group_firm_compensations
      @most_lobbied_agencies  = Agency.most_lobbied
      erb :landing
    end
    
    get "/lobbyists" do
      @current_menu = "lobbyists"
      @lobbyists = Lobbyist.all
      erb :lobbyists
    end

    get "/lobbyists/paginate/:page/:size" do
      @current_menu = "lobbyists"
      @lobbyists = Lobbyist.list_by_compensation :limit => (params[:size] || size), :offset => (params[:page] || page) #pagination_options_from(params)

      erb :lobbyists
    end

    get "/lobbyists/:id" do
      @total_paid = "%.2f" % Compensation.sum(:compensation)
      @lobbyist = Lobbyist.first :slug => params[:id]
      @actions = @lobbyist.actions.group_by { |action|
        action.purpose
      }.sort_by { |purpose| purpose }
      @agency_actions = @lobbyist.actions.group_by { |action|
        action.agency
      }.sort_by { |agency, actions| agency.name }

      erb :lobbyist
    end
    
    get "/firms" do
      @current_menu = "firms"
      @firms = Firm.list_by_compensation

      erb :firms
    end
    
    get "/firms/:id" do
      @firm = Firm.first :slug => params[:id]
      @actions = @firm.actions.group_by { |action|
        action.purpose
      }.sort_by { |purpose| purpose }
      @agency_actions = @firm.actions.group_by { |action|
        action.agency
      }.sort_by { |agency, actions| agency.name }

      erb :firm
    end
    
    get "/clients" do
      @current_menu = "clients"
      @clients = Client.list_by_lobbyists
      erb :clients
    end
    
    get "/clients/:id" do
      @client = Client.first :slug => params[:id]
      erb :client
    end
    
    get "/agencies" do
      @current_menu = "agencies"
      erb :agencies
    end
    
    get "/agencies/:id" do
      @agency = Agency.first :slug => params[:id]
      @lobbyist_actions = @agency.actions.group_by { |action|
        action.lobbyist }.sort_by { |lobbyist, actions|
          lobbyist.full_name }
      @purpose_actions = @agency.actions.group_by { |action|
          action.purpose
        }.sort_by { |purpose, actions| purpose }
      erb :agency
    end
    
    get "/:page" do |page_name|
      template = File.join(settings.views, page_name + ".erb")
      if File.exists?(template)
        @current_menu = page_name
        erb page_name.to_sym
      else
        pass
      end
    end
  end
end
