class MakeExcelJob < ApplicationJob
  queue_as :default

  def perform(homework_id)
    ExcelFile.create_excel(homework_id)
  end
end
