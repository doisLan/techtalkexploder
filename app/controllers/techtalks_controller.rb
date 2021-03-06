class TechtalksController < ApplicationController

  before_filter :authorize, except: [:list]

  def index
    if (request.query_parameters.any?)
      if request.query_parameters.include? 'keyword'
        filter
      elsif request.query_parameters.include? 'company_name'
        filterByCompanyName
      elsif request.query_parameters.include? 'begin_date'
        filterByDate
      end

    else
      @techtalks = Techtalk.order('date asc').limit(10)
    end
  end

  def filterByCompanyName
    company_name = request.query_parameters['company_name']
    @techtalks = Techtalk.where(company_name: company_name).all
  end

  def filterByDate
    begin_date = request.query_parameters['begin_date']
    end_date = request.query_parameters['end_date']
    @techtalks = Techtalk.where(['created_at BETWEEN ? and ?', "#{begin_date}%", "#{end_date}%"]).all
  end

  def new
    @techtalk = Techtalk.new
  end

  def create
    @techtalk = Techtalk.new(techtalk_params)
    respond_to do |format|
      if @techtalk.save
        format.html { redirect_to "/" }
        format.json { render :index, status: :created, location: @techtalk }
      else
        format.html { render :new }
        format.json { render json: @techtalk.errors, status: :unprocessable_entity }
      end
    end
  end

  def show
    @techtalk = Techtalk.where(id: params[:id]).take
  end

  def filter
    param = request.query_parameters['keyword']
    @techtalks = Techtalk.where(['tags LIKE ? OR title LIKE ? ', "%#{param}%", "%#{param}%"])
  end

  def calendar
  	@techtalk = Techtalk.all
  end

  private
    def techtalk_params
      params.require(:techtalk).permit(:title, :description, :date, :tags, :company_name, :url, :company_email, :token)
    end
end
