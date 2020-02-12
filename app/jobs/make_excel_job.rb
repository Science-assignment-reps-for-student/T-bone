class MakeExcelJob < ApplicationJob
  queue_as :create_excels

  def perform(homework_id)
    ExcelFile.create_excel(homework_id)
  end
end
