class CsvController < ApplicationController
	require 'csv'
	require 'prawn'
	require "prawn/table"

	def index

	end

	def buscar_pessoas
		file = params[:pessoas][:arquivo].tempfile
		subir = CSV.table(file)

		subir.each do |row|
			pessoa = Pessoa.create(nome: row.fetch(:nome),cpf: row.fetch(:cpf),cep: row.fetch(:cep))
		end
	end

	def criar_pdf
		@pessoa = Pessoa.all
		@pessoa.each do |pessoa|
			caminho = "/home/desenvolvimento/Documentos/pasta/#{pessoa.nome}.pdf" #Caminho onde irá ficar o arquivo
			Prawn::Document.generate(caminho) do |pdf|

					image = "#{Rails.root}/app/assets/images/logo.jpg"
					pdf.image image,:width => 540, :height => 150
				
				#NÃO PODE TIRAR O 'ENTER', POIS ELE FUNCIONA NO PDF
				
				pdf.bounding_box([0, 550], :width => 540, :height => 100) do
					cliente =([ [{:content =>"Nome:
					#{pessoa.nome}", :colspan =>3}],
					["RG:
					200789229-0","CPF:
					#{pessoa.cpf}","Telefone:
					99265-0685"],
					[{:content =>"Endereço:
					Av. Governador Raul Barbosa - 6686 ",:colspan =>2}, "CEP:
					#{pessoa.cep}"]
					])
					pdf.table(cliente, :row_colors =>["F0F0F0"],:cell_style =>{:padding =>[0,50,0,10]},:position =>:center)
				end

				pdf.bounding_box([50, 450], :width => 450, :height => 80) do
					vencimento =([ ["Vencimento da fatura"],["00/00/0000"]])
					pdf.table(vencimento, :row_colors =>["F0F0F0"],:cell_style =>{:padding =>[10,50,10,10]}, :position =>:left)
				end

				pdf.bounding_box([50, 450], :width => 450, :height => 80) do
					pagamento =([ ["Valor da fatura"],["R$"]])
					pdf.table(pagamento, :row_colors =>["F0F0F0"],:cell_style =>{:padding =>[10,50,10,10]}, :position =>:right)
				end

				pdf.bounding_box([50, 300], :width => 450, :height => 80) do
					pdf.text "Descrição", :size => 18, :align => :center
					pdf.text "O pagamento desse fatura deve ser feito no banco ou em uma casa loterica antes da data de vencimento, caso contrário novo boleto deverá ser solicitado por email. Em caso de novo boleto haverá um acreecismo de 5% de juros a cada dia após o vencimento.", :size => 12
				end

				# #NÃO PODE TIRAR O 'ENTER', POIS ELE FUNCIONA NO PDF
				pdf.bounding_box([15, 200], :width => 540, :height => 100) do
					cedente = ([[{:content =>"Cedente:
					Subiru Company", :colspan =>3}], [{:content =>"CNPJ:
					98.465.654/0002-65", :colspan =>3}],["Data do Documento:
					01/01/2016","Data do Processamento:
					01/01/2016","Data do Vencimento:
					01/01/2016"]
					])
					pdf.table(cedente, :row_colors =>["F0F0F0"],:cell_style =>{:padding =>[0,0,0,10]},:position =>:center)
				end

				pdf.bounding_box([15, 50], :width => 540, :height => 100) do
					image = "#{Rails.root}/app/assets/images/codigodebarra.png"
					pdf.image image, :scale => 0.5 , :position => :right
				end		
			end
		end
	end
end