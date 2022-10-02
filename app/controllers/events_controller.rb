class EventsController < ApplicationController
  def index
    @events = Event.sorted(payment_only: false)
  end

  def show
    @event = Event.find(params[:id])
    @attendances = @event.attendances.index_by(&:member_id)
    @members = Member.in(id: @attendances.keys)
    @years = Year.all.index_by(&:id)
  end

  def new
    @event = Event.new(payment_only: false)
  end

  def create
    @event = Event.new(event_params)
    unless @event.save
      render 'new', status: :unprocessable_entity
      return
    end
    redirect_to events_path
  end

  def edit
    @event = Event.find(params[:id])
  end

  def update
    @event = Event.find(params[:id])
    unless @event.update(event_params)
      render 'edit', status: :unprocessable_entity
      return
    end
    redirect_to events_path
  end

  def destroy
    @event = Event.find(params[:id])
    @event.destroy
    redirect_to(events_path, notice: "#{@event.event_name}を削除しました。")
  end

  private

  def event_params
    params.require(:event).permit(
      :event_name,
      :event_date,
      :fee,
      :payment_only,
      :note
    )
  end
end
