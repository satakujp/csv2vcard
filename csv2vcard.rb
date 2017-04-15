# -*- coding: utf-8 -*-
require 'rubygems'
require 'kconv'
require 'csv'
require 'vpim'
$KCODE='u'
#Authors::   takuya_1st
#Copyright:: @takuya_1st
#License::   GPL
class CSV 
    ## CSVファイルを読み込んで一行目を見出し行として、全部をハッシュに読み込む
    def CSV.csv_to_hash(filename)
        #一行目がヘッダのCSVファイル
        f = CSV.open(filename, "r") 
        header = f.shift
        f.map{|e| 
            Hash[*header.zip(e).flatten]
        }
    end

end


class LismoAddressBook


    def csv_to_vcf_array(filename)
        info_list = csv_to_info(filename)
        vcf_list = info_list.map{|info,k|
            info_to_vcf(info)
        }
    end

    def csv_into_vcf_files(filename)
        list = csv_to_info(filename)
        list.each{|info| 
            save_vcf(info)
        }
    end


    def csv_to_info(csv_file)
        hash_list = CSV.csv_to_hash(csv_file)
        hash_list.map{|e| 
            hash_to_info(e)
        }
    end
    def hash_to_info(hash)
        info ={};

        info['f_name'] = hash["名"]
        info['l_name'] = hash["姓"]
        info['f_kana'] = hash["めい"]
        info['l_kana'] = hash["せい"]
        info['postal'] = hash["郵便番号"]
        info['pref'] = hash["都道府県"]
        info['addr'] = hash["住所"]

        # Phone number as array, to store maltiple numbers.
        info['tel'] = [hash["電話番号"]]

        return info
    end
    def info_to_vcf(info)

        vcard = Vpim::Vcard.create
        vcard << Vpim::DirectoryInfo::Field.create('N;CHARSET=utf-8'        , "#{info['l_name']};#{info['f_name']};;;"  )
        vcard << Vpim::DirectoryInfo::Field.create('FN;CHARSET=utf-8'       , "#{info['f_name']} #{info['l_name']}"      )
        vcard << Vpim::DirectoryInfo::Field.create('X-PHONETIC-FIRST-NAME'  , "#{info['f_kana']}"      )
        vcard << Vpim::DirectoryInfo::Field.create('X-PHONETIC-LAST-NAME'  , "#{info['l_kana']}"      )

        info["email"].each{|mail|
            vcard << Vpim::DirectoryInfo::Field.create('EMAIL;INTERNET'     , "#{mail}" )
        } if info["email"]

        info["tel"].each{|num|
            vcard << Vpim::DirectoryInfo::Field.create('TEL;CELL;VOICE'     , "#{num}" )
        } if info["tel"]
        
        vcard << Vpim::DirectoryInfo::Field.create('ADR;HOME;pref;CHARSET=utf-8' , ";;#{info['addr']};;#{info["pref"]};#{info["postal"]};" )

        vcard << Vpim::DirectoryInfo::Field.create('BDAY;value=date'        , "#{info['birthday']}" ) if info["birthday"]
        vcard << Vpim::DirectoryInfo::Field.create('NOTE;CHARSET=utf-8'     , "#{info['memo']}" ) if info["memo"]
        vcard.to_s.gsub( /¥r?¥n/, "")
    end

    def save_vcf(info)
        require 'digest/sha1'
        vcf_string = info_to_vcf(info)
        file_name = "#{info["f_name"]}#{info["l_name"]}.vcf"
        file_name = "#{Digest::SHA1.hexdigest(vcf_string)}.vcf" if file_name.strip == ".vcf"
        open("vcards/#{info["f_name"]}#{info["l_name"]}.vcf", "w" ){|f|
            f.write vcf_string
        }
        puts "#{file_name} saved."
    end
end

converter = LismoAddressBook.new 
converter.csv_into_vcf_files("./address.csv")
