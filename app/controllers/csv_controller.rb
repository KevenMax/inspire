class CsvController < ApplicationController
	before_action :authenticate_usuario!
	require 'csv'
	require 'prawn'
	require "prawn/table"

	def index
		@empresa = Empresa.all
	end

	def sel_empresa
	end

	def empresa_tabela
		@sel_empresa = params[:empresa][:empresa_id]
		@cod = Pessoa.select(:codigo, :created_at, :empresa_id).where(:empresa_id => @sel_empresa).group_by(&:codigo)
	end

	def tabela
		@info = Pessoa.where("ativo= ? and codigo=?", 'true', @cod)
		@inv = Pessoa.where("ativo= ? and codigo=?", 'false', @cod)
	end

	def buscar_pessoas
		if params[:pessoas][:arquivo].content_type == "text/csv"
			id = params[:pessoas][:empresa_id]
			file = params[:pessoas][:arquivo].tempfile
			subir = CSV.table(file)
			codigo = Pessoa.order(id: :asc).last
			if codigo.nil?
				codigo = 1
			else
				codigo = codigo.codigo.to_i + 1
			end
			subir.each do |row|
				
				cpf = row.fetch(:cpf)
				email = row.fetch(:email)
				cep = row.fetch(:cep)

				if !cpf.nil? && !email.nil? && !cep.nil?
					pessoa = Pessoa.create(
					nome: row.fetch(:nome),
					cpf: row.fetch(:cpf),
					rg: row.fetch(:rg),
					telefone: row.fetch(:telefone),
					endereco: row.fetch(:endereco),
					cep: row.fetch(:cep),
					valor: row.fetch(:valor),
					vencimento: row.fetch(:vencimento),
					cnpj: row.fetch(:cnpj),
					email: row.fetch(:email),
					ativo:  true,
					codigo: codigo,
					empresa_id: id)
				else
					pessoa = Pessoa.create(
					nome: row.fetch(:nome),
					cpf: row.fetch(:cpf),
					rg: row.fetch(:rg),
					telefone: row.fetch(:telefone),
					endereco: row.fetch(:endereco),
					cep: row.fetch(:cep),
					valor: row.fetch(:valor),
					vencimento: row.fetch(:vencimento),
					cnpj: row.fetch(:cnpj),
					email: row.fetch(:email),
					ativo:  false,
					codigo: codigo,
					empresa_id: id)
				end
			end
			flash[:notice] = "O arquivo foi processado com sucesso!"
					
			@info = Pessoa.all
			redirect_to :controller => 'csv', :action => 'tabela' 
		else
			redirect_to :controller => 'csv', :action => 'index'
			flash[:notice] = "O arquivo não é do tipo CSV! \n Por favor, submeta um arquivo do tipo CSV."
			
		end
	end

	def criar_pdf
		@pessoa = Pessoa.all
		@pessoa.each do |p|
			@caminho = "/home/keven/Documentos/pasta/#{p.codigo}.pdf" #Caminho onde irá ficar o arquivo
		end
		Prawn::Document.generate(@caminho) do |pdf|
			@pessoa.each do |pessoa|
				if pessoa.ativo?
					image = "#{Rails.root}/app/assets/images/logo.jpg"
					pdf.image image,:width => 540, :height => 150
					
					#NÃO PODE TIRAR O 'ENTER', POIS ELE FUNCIONA NO PDF
					
					pdf.bounding_box([0, 550], :width => 540, :height => 100) do
						cliente =([ [{:content =>"Nome:
						#{pessoa.nome}", :colspan =>3}],
						["RG:
						#{pessoa.rg}","CPF:
						#{pessoa.cpf}","Telefone:
						#{pessoa.telefone}"],
						[{:content =>"Endereço:
						#{pessoa.endereco}",:colspan =>2}, "CEP:
						#{pessoa.cep}"]
						])
						pdf.table(cliente, :row_colors =>["F0F0F0"],:cell_style =>{:padding =>[0,50,0,10]},:position =>:center)
					end

					pdf.bounding_box([50, 450], :width => 450, :height => 80) do
						vencimento =([ ["Vencimento da fatura"],["#{pessoa.vencimento}"]])
						pdf.table(vencimento, :row_colors =>["F0F0F0"],:cell_style =>{:padding =>[10,50,10,10]}, :position =>:left)
					end

					pdf.bounding_box([50, 450], :width => 450, :height => 80) do
						pagamento =([ ["Valor da fatura"],["#{pessoa.valor}"]])
						pdf.table(pagamento, :row_colors =>["F0F0F0"],:cell_style =>{:padding =>[10,50,10,10]}, :position =>:right)
					end

					pdf.bounding_box([50, 300], :width => 450, :height => 80) do
						pdf.text "Descrição", :size => 18, :align => :center
						pdf.text "O pagamento desse fatura deve ser feito no banco ou em uma casa loterica antes da data de vencimento, caso contrário novo boleto deverá ser solicitado por email. Em caso de novo boleto haverá um acreecismo de 5% de juros a cada dia após o vencimento.", :size => 12
					end

					# #NÃO PODE TIRAR O 'ENTER', POIS ELE FUNCIONA NO PDF
					pdf.bounding_box([15, 200], :width => 540, :height => 100) do
						cedente = ([[{:content =>"Cedente:
						#{pessoa.empresa.nome}", :colspan =>3}], [{:content =>"CNPJ:
						#{pessoa.cnpj}", :colspan =>3}],["Data do Documento:
						#{pessoa.vencimento}","Data do Processamento:
						#{pessoa.vencimento}","Data do Vencimento:
						#{pessoa.vencimento}"]
						])
						pdf.table(cedente, :row_colors =>["F0F0F0"],:cell_style =>{:padding =>[0,0,0,10]},:position =>:center)
					end

					pdf.bounding_box([15, 50], :width => 540, :height => 100) do
						image = "#{Rails.root}/app/assets/images/codigodebarra.png"
						pdf.image image, :scale => 0.5 , :position => :right
					end
					pdf.start_new_page		
				end
			end
		end
		flash[:notice] = "PDF's gerados com sucesso dentro do diretório 'Documentos'!"
		redirect_to :controller => 'csv', :action => 'tabela'
	end

	def criar_pdf_separado
			
	end
end
