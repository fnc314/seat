ActiveAdmin.register Reservation do
  config.sort_order = "created_at_asc"

  form do |f|
    f.inputs "Reservation" do
      f.input :party_size
      f.input :begin, :as => :datetime_select, :options => {:twelve_hour => true, :ampm => true, :minute_step => 30, :start_hour => 18, :end_hour => 21}
      f.input :table_ids, :as => :check_boxes, :collection => Table.all.sort
      f.input :server
    end
    
    f.actions
  end

  filter :server
  filter :party_size
  filter :tables

  # Index Page (admin/reservations)
  index do
    column(:date) { |res| res.begin.to_date.strftime("%A %b. %d, %Y") }
    column(:time) { |res| (res.begin.to_time + 8.hours).strftime("%l:%M %p") }
    column :party_size
    column(:server_id) { |res| Server.find(res.server_id).name }
    column(:tables) do |res|
      table_string = "" 
      res.tables.all.sort.each { |t| table_string += " " + t.to_list + " "}
      table_string
    end
    column(:table_count) { |res| res.tables.count }
    column(:available_seat_count) do |res|
      available_seat_count = 0
      res.tables.all.sort.each { |t| available_seat_count += t.capacity }
      available_seat_count
    end
    default_actions   
  end

  # Show Page (admin/reservation/:id)
  show do |reservation|
    attributes_table do
      row :restaurant
      row :id
      row(:date) { |res| res.begin.to_date.strftime("%A %b. %d, %Y") }
      row(:start) { |res| (res.begin.to_time + 8.hours).strftime("%l:%M %p") }
      row(:end) { |res| (res.end.to_time + 8.hours).strftime("%l:%M %p") }
      row :party_size
      row(:server_id) { |res| Server.find(res.server_id).name }
      row(:tables) do |res|
        table_string = "" 
        res.tables.all.sort.each { |t| table_string += "#{t.id}" + " "}
        table_string
      end
    end
  end

  controller do

    def permitted_params
      params.permit reservation: [ :begin, :end, :party_size, :server_id, :table_ids, :image_file_size ]
    end

    def update
      permitted_params
      
      res = Reservation.find(params[:id])
      
      # First get table information for reservation
      tables_ids = params[:reservation][:table_ids]
      tables = tables_ids.map { |t| t if t != "" }
      # removes the nil from check_boxes
      tables = tables.compact 
      # Convert from strings like "1" to integers 1
      tables = tables.map! { |t| Table.find(t) }
      # Update reservation table assignment
      res.tables = tables
      
      # Second get date information changes (using original reservations_controller.rb on line 67)
      res_begin = params[:reservation]
      new_begin = DateTime.new(res_begin["begin(1i)"].to_i, res_begin["begin(2i)"].to_i, res_begin["begin(3i)"].to_i, res_begin["begin(4i)"].to_i, res_begin["begin(5i)"].to_i)
      # set res.begin to newly created DateTime object
      res.begin = new_begin
      # recalculate res.end by adding 90 minutes to new_begin
      res.end = new_begin + 90.minutes
      
      
      # Third get new server information
      serverid = params[:reservation][:server_id]
      # Convert to integer
      serverid = serverid.to_i
      # set res.server_id to the new serverid
      res.server_id = serverid
      

      # Finally get new party_size information
      partysize = params[:reservation][:party_size]
      # Convert to integer
      partysize = partysize.to_i
      # set res.party_size to the new partysize
      res.party_size = partysize
      
      # Save changes and commit to database
      res.save
      redirect_to admin_reservation_path(res.id)
    end


  end

  
  # See permitted parameters documentation:
  # https://github.com/gregbell/active_admin/blob/master/docs/2-resource-customization.md#setting-up-strong-parameters
  #
  # permit_params :list, :of, :attributes, :on, :model
  #
  # or  "Server", name  #{ |reservation| Server.find(reservation.server_id).name }
  #
  # permit_params do
  #  permitted = [:permitted, :attributes]
  #  permitted << :other if resource.something?
  #  permitted
  # end
  
end
