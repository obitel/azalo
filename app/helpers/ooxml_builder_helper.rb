# -*- encoding : utf-8 -*-


module OoxmlBuilderHelper
  PageWidth = 11906
  PageHeight = 16838
  PageMarginTop = 1969
  PageMarginLeft = 1134
  PageMarginRight = 1134
  PageMarginBottom = 2079
  PageMarginHeader = 1134
  PageMarginFooter = 1134


  Styles = {
      :base => 'style0',
      :bq => 'style25',
      :code => 'style15',
  }

  load "#{Rails.root}/lib/red_cloth_formatters_ooxml.rb"

  def new_builder
    buffer = ''
    return [Builder::XmlMarkup.new(:target => buffer), buffer]
  end

  def ooxml_document(&block)
    builder, buffer = new_builder
    builder.w :document,
          'xmlns:o' => 'urn:schemas-microsoft-com:office:office',
          'xmlns:r' => 'http://schemas.openxmlformats.org/officeDocument/2006/relationships',
          'xmlns:v' => 'urn:schemas-microsoft-com:vml',
          'xmlns:w' => 'http://schemas.openxmlformats.org/wordprocessingml/2006/main',
          'xmlns:w10' => 'urn:schemas-microsoft-com:office:word',
          'xmlns:wp' => 'http://schemas.openxmlformats.org/drawingml/2006/wordprocessingDrawing' do
      buffer << yield.to_s
    end
    return buffer
  end

  def ooxml_body(&block)
    builder, buffer = new_builder
    builder.w :body do
      buffer << yield.to_s
    end
    return buffer
  end

  def ooxml_period(opts = [], &block)
    builder, buffer = new_builder
    builder.w :r do
      builder.w :rPr do
        if opts.include? :ins
          builder << '<w:i w:val="false"/><w:iCs w:val="false"/><w:u w:val="single"/>'
        end
        if opts.include?(:em) || opts.include?(:i)
          builder << '<w:i/><w:iCs/>'
        end
        if opts.include?(:strong) || opts.include?(:b)
          builder << '<w:b/><w:bCs/>'
        end
        if opts.include? :del
          builder << '<w:b w:val="false"/><w:bCs w:val="false"/><w:i w:val="false"/><w:iCs w:val="false"/><w:strike/>'
        end
        if opts.include? :sup
          builder << '<w:b w:val="false"/><w:bCs w:val="false"/><w:i w:val="false"/><w:iCs w:val="false"/><w:u w:val="none"/><w:vertAlign w:val="superscript"/>'
        end
        if opts.include? :sub
          builder << '<w:b w:val="false"/><w:bCs w:val="false"/><w:i w:val="false"/><w:iCs w:val="false"/><w:u w:val="none"/><w:vertAlign w:val="subscript"/>'
        end
        if opts.include? :code
          '<w:rStyle w:val="style15"/>'
          builder << '<w:rStyle w:val="style20"/>'
        end
      end
      builder.w :t do
        buffer << yield.to_s
      end
    end
    return buffer
  end

  def ooxml_simple_text_paragraph(&block)
    builder, buffer = new_builder
    builder.w :p do
      builder.w :pPr do
        builder.w :pStyle, 'w:val' => Styles[:base]
        #builder.w :pStyle, 'w:val' => 'style16'
      end
      buffer << ooxml_period(&block).to_s
    end
    return buffer
  end

  def ooxml_textile_text(&block)
    #builder, buffer = new_builder
    #buffer << ooxml_paragraph do
      #RedCloth.new(yield).to_ooxml
    #end

    rc = RedCloth.new(yield)
    return rc.to_ooxml
  end

  def ooxml_paragraph(&block)
    builder, buffer = new_builder
    builder.w :p do
      builder.w :pPr do
        builder.w :pStyle, 'w:val' => Styles[:base]
      end
      buffer << yield.to_s
    end
    return buffer
  end

  def ooxml_block_quote(&block)
    builder, buffer = new_builder
    builder.w :p do
      builder.w :pPr do

        #<w:pStyle w:val="style25"/>
        builder.w :pStyle, 'w:val' => Styles[:bq]

        #<w:spacing w:after="283" w:before="0"/>
        builder.w :spacing, 'w:after' => '283', 'w:before' => '0'

        #<w:ind w:hanging="0" w:left="567" w:right="567"/>
        builder.w :ind, 'w:hanging' => '0', 'w:left' => '567', 'w:right' => '567'

      end
      buffer << yield.to_s
    end
    return buffer
  end


  def ooxml_code(&block)
    builder, buffer = new_builder
    builder.w :p do
      builder.w :pPr do

        '<w:p>
          <w:pPr>
            <w:pStyle w:val="style0"/>
          </w:pPr>
          <w:r>
            <w:rPr>
              <w:rStyle w:val="style15"/>
            </w:rPr>
            <w:t>Some code</w:t>
          </w:r>
        </w:p>'

        #<w:pStyle w:val="style25"/>
        builder.w :pStyle, 'w:val' => Styles[:base]

        #<w:spacing w:after="283" w:before="0"/>
        builder.w :spacing, 'w:after' => '283', 'w:before' => '0'

        #<w:ind w:hanging="0" w:left="567" w:right="567"/>
        builder.w :ind, 'w:hanging' => '0', 'w:left' => '567', 'w:right' => '567'

      end
      buffer << yield.to_s
    end
    return buffer
  end

  def ooxml_sect_pr(&block)
    builder, buffer = new_builder
    builder.w :sectPr do
      builder.w :headerReference, 'r:id' => 'rId2', 'w:type' => 'default'
      builder.w :footerReference, 'r:id' => 'rId3', 'w:type' => 'default'
      builder.w :type, 'w:val' => 'nextPage'
      builder.w :pgSz, 'w:h' => PageHeight.to_s, 'w:w' => PageWidth.to_s
      builder.w :pgMar,
                'w:bottom' => PageMarginBottom.to_s,
                'w:footer' => PageMarginFooter.to_s,
                'w:gutter' => '0',
                'w:header' => PageMarginHeader.to_s,
                'w:left' => PageMarginLeft.to_s,
                'w:right' => PageMarginRight.to_s,
                'w:top' => PageMarginTop.to_s

      builder.w :pgNumType, 'w:fmt' => 'decimal'
      builder.w :formProt, 'w:val' => 'false'
      builder.w :textDirection, 'w:val' => 'lrTb'
      builder.w :docGrid, 'w:charSpace' => '0', 'w:linePitch' => '240', 'w:type' => 'default'
    end
    return buffer
  end

  def ooxml_hL(level, &block)
    builder, buffer = new_builder
    params = {
        1 => {
            :pstyle => 'style1',
            :ilvl => '0',
            :numId => '1',
            :spacing => true,
            :spacing_after => '120',
            :spacing_before => '240'
        },
        2 => {
            :pstyle => 'style2',
            :ilvl => '1',
            :numId => '1',
            :spacing => false
        },
        3 => { #TODO h3 = h2
            :pstyle => 'style2',
            :ilvl => '1',
            :numId => '1',
            :spacing => false
        },
        4 => { #TODO h4 = h2
               :pstyle => 'style2',
               :ilvl => '1',
               :numId => '1',
               :spacing => false
        },
        5 => { #TODO h5 = h2
               :pstyle => 'style2',
               :ilvl => '1',
               :numId => '1',
               :spacing => false
        },

    }
    builder.w :p do
      builder.w :pPr do
        builder.w :pStyle, 'w:val' => params[level][:pstyle]
        builder.w :numPr do
          builder.w :ilvl, 'w:val' => params[level][:ilvl]
          builder.w :numId, 'w:val' => params[level][:numId]
        end
        if params[level][:spacing]
          builder.w :spacing, 'w:after' => params[level][:spacing_after], 'w:before' => params[level][:spacing_before]
        end
      end
      buffer << ooxml_period(&block).to_s
    end
    return buffer
  end

  def ooxml_h1(&block)
    ooxml_hL(1, &block)
  end

  def ooxml_h2(&block)
    ooxml_hL(2, &block)
  end

  def ooxml_h3(&block)
    ooxml_hL(3, &block)
  end

  def ooxml_h4(&block)
    ooxml_hL(4, &block)
  end

  def ooxml_h5(&block)
    ooxml_hL(4, &block)
  end

  def ooxml_h6(&block)
    ooxml_hL(4, &block)
  end

  def ooxml_page_break
    builder, buffer = new_builder
    ooxml_paragraph do
      builder.w :pPr do
        builder.w :pageBreakBefore
      end
    end
    return buffer
  end

  def ooxml_table(row_num, col_num, table_width, &block)
    builder, buffer = new_builder
    builder.w :tbl do
      ooxml_table_pr
      ooxml_table_grid(col_num, table_width)
      0.upto(row_num - 1) do |r|
        ooxml_table_tr(r, col_num, &block)
      end
    end
    return buffer
  end

  def ooxml_table_pr
    builder, buffer = new_builder
    builder.w :tblPr do
      builder.w :tblW, 'w:type' => 'dxa', 'w:w' => 'table_width'
      builder.w :jc, 'w:val' => 'left'
      builder.w :tblBorders do
        builder.w :top, 'w:color' => '000000', 'w:space' => '0', 'w:sz' => '2', 'w:val' => 'single'
        builder.w :left, 'w:color' => '000000', 'w:space' => '0', 'w:sz' => '2', 'w:val' => 'single'
        builder.w :bottom, 'w:color' => '000000', 'w:space' => '0', 'w:sz' => '2', 'w:val' => 'single'
      end
    end
    return buffer
  end

  def ooxml_table_tr(row_num, col_num, &block)
    builder, buffer = new_builder
    builder.w :tr do
      ooxml_table_tr_pr
      0.upto(col_num - 1) do |c|
        ooxml_table_tc(row_num, c, c = col_num - 1, &block)
      end
    end
    return buffer
  end

  def ooxml_table_tr_pr
    builder, buffer = new_builder
    builder.w :trPr do
      builder.w :cantSplit, 'w:val' => 'false'
    end
    return buffer
  end

  def ooxml_table_tc(row_num, col_num, last_in_row, &block)
    builder, buffer = new_builder
    builder.w :tc do
      ooxml_table_tc_pr(row_num == 0, last_in_row)
      ooxml_paragraph do
        ooxml_period do
          block.call(row_num, col_num)
        end
      end
    end
    return buffer
  end

  def ooxml_table_tc_pr(header, last_in_row)
    builder, buffer = new_builder
    builder.w :tcPr do
      builder.w :tcBorders do
        builder.w :top, 'w:color' => '000000', 'w:space' => '0', 'w:sz' => '2', 'w:val' => 'single'
        builder.w :left, 'w:color' => '000000', 'w:space' => '0', 'w:sz' => '2', 'w:val' => 'single'
        builder.w :bottom, 'w:color' => '000000', 'w:space' => '0', 'w:sz' => '2', 'w:val' => 'single'
        builder.w :right, 'w:color' => '000000', 'w:space' => '0', 'w:sz' => '2', 'w:val' => 'single' if last_in_row
      end
      builder.w :tcMar do
        builder.w :top, 'w:type' => 'dxa', 'w:w' => '5'
        builder.w :left, 'w:type' => 'dxa', 'w:w' => '5'
        builder.w :bottom, 'w:type' => 'dxa', 'w:w' => '5'
        builder.w :right, 'w:type' => 'dxa', 'w:w' => '5'
      end
      color = header ? 'CFE7F5' : 'auto'
      builder.w :shd, 'w:fill' => color, 'w:val' => 'clear'
    end
    return buffer
  end

  def ooxml_table_grid(col_num, table_width)
    builder, buffer = new_builder
    column_width = table_width / col_num
    last_column_width = table_width - column_width * (col_num - 1)

    builder.w :tblGrid do
      1.upto(col_num - 1) do
        builder.w :gridCol, 'w:w' => "#{column_width}"
      end
      if col_num > 1
        builder.w :gridCol, 'w:w' => "#{last_column_width}"
      end
    end
    return buffer
  end

=begin

  def ooxml_picture(builder, image_rel_id, original_image_path)
    begin
    img = Magick::Image::read(original_image_path).first
    rescue

      ret = ooxml_simple_text_paragraph(builder) do
        'File not found'
      end
      return ret
    end
    puts '-------------------------------------------------------------------------------------------------------------'
    puts "File name: #{original_image_path} rel_id: #{image_rel_id}"
    puts "   Geometry: #{img.columns}x#{img.rows}"
    puts "   Resolution: #{img.x_resolution.to_i}x#{img.y_resolution.to_i} pixels/#{img.units == Magick::PixelsPerInchResolution ? "inch" : "centimeter"}"


    if img.units == Magick::PixelsPerInchResolution
      y_resolution = img.y_resolution.to_i
      x_resolution = img.x_resolution.to_i
    else
      y_resolution = (img.y_resolution.to_i / 2.54).to_i
      x_resolution = (img.x_resolution.to_i / 2.54).to_i
    end

    x_resolution = 96
    y_resolution = 96

        image_x_inches = img.columns / x_resolution
    image_y_inches = img.rows / y_resolution

    k =   11.694 / 16939.0

    image_description_holder = PageMarginTop * 2

    page_area_x = PageWidth - PageMarginLeft - PageMarginRight
    page_area_y = PageHeight - PageMarginTop - PageMarginBottom - PageMarginHeader - PageMarginFooter - image_description_holder

    page_x_inches = page_area_x * k
    page_y_inches = page_area_y * k

    puts "image size in inches: #{image_x_inches}x#{image_y_inches}"
    puts "page size in inches: #{page_x_inches}x#{page_y_inches}"

    kx = 914400.0 / x_resolution
    ky = 914400.0 / y_resolution

    cx = (img.columns * kx).to_i
    cy = (img.rows * ky).to_i

    puts "1 cx = #{cx}, cy = #{cy}"

    ksx = Float(page_x_inches)/image_x_inches
    ksy = Float(page_y_inches)/image_y_inches

    puts "ksx = #{ksx} ksy = #{ksy}"

    if ksx < 1 || ksy < 1
      ks = [ksx, ksy].min
      cx = (cx * ks).to_i
      cy = (cy * ks).to_i
    end

    puts "2 cx = #{cx}, cy = #{cy}"



    x1 = '<w:pPr>
        <w:pStyle w:val="style17"/>
        <w:spacing w:after="120" w:before="0"/>
      </w:pPr>
      <w:r>
        <w:rPr/>
        <w:drawing>
          <wp:anchor allowOverlap="1" behindDoc="0" distB="0" distL="0" distR="0" distT="0" layoutInCell="1" locked="0" relativeHeight="0" simplePos="0">
            <wp:simplePos x="0" y="0"/>
            <wp:positionH relativeFrom="character">
              <wp:posOffset>0</wp:posOffset>
            </wp:positionH>
            <wp:positionV relativeFrom="line">
              <wp:posOffset>0</wp:posOffset>
            </wp:positionV>
            <wp:extent cx="' + cx.to_s + '" cy="' + cy.to_s + '"/>
            <wp:effectExtent b="0" l="0" r="0" t="0"/>
            <wp:wrapTopAndBottom/>
            <wp:docPr descr="A description..." id="1" name="Picture"/>
            <wp:cNvGraphicFramePr>
              <a:graphicFrameLocks xmlns:a="http://schemas.openxmlformats.org/drawingml/2006/main" noChangeAspect="1"/>
            </wp:cNvGraphicFramePr>
            <a:graphic xmlns:a="http://schemas.openxmlformats.org/drawingml/2006/main">
              <a:graphicData uri="http://schemas.openxmlformats.org/drawingml/2006/picture">
                <pic:pic xmlns:pic="http://schemas.openxmlformats.org/drawingml/2006/picture">
                  <pic:nvPicPr>
                    <pic:cNvPr descr="A description..." id="0" name="Picture"/>
                    <pic:cNvPicPr>
                      <a:picLocks noChangeArrowheads="1" noChangeAspect="1"/>
                    </pic:cNvPicPr>
                  </pic:nvPicPr>
                  <pic:blipFill>
                    <a:blip r:embed="' + image_rel_id + '"/>
                    <a:srcRect/>
                    <a:stretch>
                      <a:fillRect/>
                    </a:stretch>
                  </pic:blipFill>
                  <pic:spPr bwMode="auto">
                    <a:xfrm>
                      <a:off x="0" y="0"/>
                      <wp:extent cx="' + cx.to_s + '" cy="' + cy.to_s + '"/>
                    </a:xfrm>
                    <a:prstGeom prst="rect">
                      <a:avLst/>
                    </a:prstGeom>
                    <a:noFill/>
                    <a:ln w="9525">
                      <a:noFill/>
                      <a:miter lim="800000"/>
                      <a:headEnd/>
                      <a:tailEnd/>
                    </a:ln>
                  </pic:spPr>
                </pic:pic>
              </a:graphicData>
            </a:graphic>
          </wp:anchor>
        </w:drawing>
      </w:r>'


    x = '
      <w:pPr>
        <w:pStyle w:val="style17"/>
        <w:spacing w:after="120" w:before="0"/>
      </w:pPr>
      <w:r>
        <w:rPr/>
        <w:drawing>
          <wp:anchor allowOverlap="1" behindDoc="0" distB="0" distL="0" distR="0" distT="0" layoutInCell="1" locked="0" relativeHeight="0" simplePos="0">
            <wp:simplePos x="0" y="0"/>
            <wp:positionH relativeFrom="column">
              <wp:posOffset>0</wp:posOffset>
            </wp:positionH>
            <wp:positionV relativeFrom="paragraph">
              <wp:posOffset>0</wp:posOffset>
            </wp:positionV>
            <wp:extent cx="' + cx.to_s + '" cy="' + cy.to_s + '"/>
            <wp:effectExtent b="0" l="0" r="0" t="0"/>
            <wp:wrapSquare wrapText="bothSides"/>
            <wp:docPr descr="A description..." id="1" name="Picture"/>
            <wp:cNvGraphicFramePr>
              <a:graphicFrameLocks xmlns:a="http://schemas.openxmlformats.org/drawingml/2006/main" noChangeAspect="1"/>
            </wp:cNvGraphicFramePr>
            <a:graphic xmlns:a="http://schemas.openxmlformats.org/drawingml/2006/main">
              <a:graphicData uri="http://schemas.openxmlformats.org/drawingml/2006/picture">
                <pic:pic xmlns:pic="http://schemas.openxmlformats.org/drawingml/2006/picture">
                  <pic:nvPicPr>
                    <pic:cNvPr descr="A description..." id="0" name="Picture"/>
                    <pic:cNvPicPr>
                      <a:picLocks noChangeArrowheads="1" noChangeAspect="1"/>
                    </pic:cNvPicPr>
                  </pic:nvPicPr>
                  <pic:blipFill>
                    <a:blip r:embed="' + image_rel_id + '"/>
                    <a:srcRect/>
                    <a:stretch>
                      <a:fillRect/>
                    </a:stretch>
                  </pic:blipFill>
                  <pic:spPr bwMode="auto">
                    <a:xfrm>
                      <a:off x="0" y="0"/>
                    </a:xfrm>
                    <a:prstGeom prst="rect">
                      <a:avLst/>
                    </a:prstGeom>
                    <a:noFill/>
                    <a:ln w="9525">
                      <a:noFill/>
                      <a:miter lim="800000"/>
                      <a:headEnd/>
                      <a:tailEnd/>
                    </a:ln>
                  </pic:spPr>
                </pic:pic>
              </a:graphicData>
            </a:graphic>
          </wp:anchor>
        </w:drawing>
      </w:r>'

    builder.w :p do |p|
      p << x1
    end

  end


=begin
def ooxml_picture(builder, image, image_counter)
    image_id = "tr_image#{image_counter}"
    x = '
      <w:pPr>
        <w:pStyle w:val="style17"/>
        <w:spacing w:after="120" w:before="0"/>
      </w:pPr>
      <w:r>
        <w:rPr/>
        <w:drawing>
          <wp:anchor allowOverlap="1" behindDoc="0" distB="0" distL="0" distR="0" distT="0" layoutInCell="1" locked="0" relativeHeight="0" simplePos="0">
            <wp:simplePos x="0" y="0"/>
            <wp:positionH relativeFrom="column">
              <wp:posOffset>0</wp:posOffset>
            </wp:positionH>
            <wp:positionV relativeFrom="paragraph">
              <wp:posOffset>0</wp:posOffset>
            </wp:positionV>
            <wp:extent cx="6120130" cy="4589780"/>
            <wp:effectExtent b="0" l="0" r="0" t="0"/>
            <wp:wrapSquare wrapText="largest"/>
            <wp:docPr descr="A description..." id="1" name="Picture"/>
            <wp:cNvGraphicFramePr>
              <a:graphicFrameLocks xmlns:a="http://schemas.openxmlformats.org/drawingml/2006/main" noChangeAspect="1"/>
            </wp:cNvGraphicFramePr>
            <a:graphic xmlns:a="http://schemas.openxmlformats.org/drawingml/2006/main">
              <a:graphicData uri="http://schemas.openxmlformats.org/drawingml/2006/picture">
                <pic:pic xmlns:pic="http://schemas.openxmlformats.org/drawingml/2006/picture">
                  <pic:nvPicPr>
                    <pic:cNvPr descr="A description..." id="0" name="Picture"/>
                    <pic:cNvPicPr>
                      <a:picLocks noChangeArrowheads="1" noChangeAspect="1"/>
                    </pic:cNvPicPr>
                  </pic:nvPicPr>
                  <pic:blipFill>
                    <a:blip r:embed="' + image_id + '"/>
                    <a:srcRect/>
                    <a:stretch>
                      <a:fillRect/>
                    </a:stretch>
                  </pic:blipFill>
                  <pic:spPr bwMode="auto">
                    <a:xfrm>
                      <a:off x="0" y="0"/>
                      <a:ext cx="6120130" cy="4589780"/>
                    </a:xfrm>
                    <a:prstGeom prst="rect">
                      <a:avLst/>
                    </a:prstGeom>
                    <a:noFill/>
                    <a:ln w="9525">
                      <a:noFill/>
                      <a:miter lim="800000"/>
                      <a:headEnd/>
                      <a:tailEnd/>
                    </a:ln>
                  </pic:spPr>
                </pic:pic>
              </a:graphicData>
            </a:graphic>
          </wp:anchor>
        </w:drawing>
      </w:r>'

    builder.w :p do |p|
      p << x
    end

  end
=end


end




