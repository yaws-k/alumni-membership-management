class YearsController < ApplicationController
  before_action :check_roles_years

  def index
    @years = Year.all.sort(anno_domini: :desc)
  end

  def new
    @year = Year.new
  end

  def create
    @year = Year.new(year_params)
    unless @year.save
      render :new, status: :unprocessable_entity
      return
    end

    redirect_to years_path
  end

  def edit
    @year = Year.find(params[:id])
  end

  def update
    @year = Year.find(params[:id])
    unless @year.update(year_params)
      render :edit, status: :unprocessable_entity
      return
    end

    redirect_to years_path
  end

  def destroy
    @year = Year.find(params[:id])
    if @year.members.first.present?
      # Year must not have any members when deleted
      redirect_to years_path, alert: '紐付くメンバーが存在する年次は消せません。'
      return
    end

    @year.destroy
    redirect_to years_path
  end

  private

  def year_params
    params.require(:year).permit(
      :graduate_year,
      :anno_domini,
      :japanese_calendar
    )
  end

  def check_roles_years
    # Admin only
    return true if @roles[:admin]

    # Access denied
    redirect_to(members_path, alert: 'Access denied')
  end
end
