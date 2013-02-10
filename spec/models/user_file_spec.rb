# -*- encoding: utf-8 -*-
require 'spec_helper'

describe UserFile do
  fixtures []

  let(:user) { mock_model(User, id: 999) }
  let(:category) { :manifestation_list }
  let(:filename) { 'foobar.pdf' }

  before do
    @tmpdir = Dir.mktmpdir
    @save_base_dir = UserFile.base_dir
    UserFile.base_dir = @tmpdir
  end

  after do
    UserFile.base_dir = @save_base_dir
    FileUtils.remove_entry_secure(@tmpdir)
  end

  def path_should_be_valid(path, owner = user)
    File.fnmatch("#{@tmpdir}/#{owner.id},#{category},*,#{filename}", path).should be_true
  end

  describe '.newは' do
    it '第一引数で与えられたUserレコードを@userに設定すること' do
      user_file = UserFile.new(user)
      user_file.user.should be_eql(user)
    end
  end

  describe '#createは' do
    subject { UserFile.new(user) }

    it '指定されたカテゴリ、名前に対応するファイルを生成してFileオブジェクトとファイル情報を返すこと' do
      file, info = subject.create(category, filename)

      file.should be_a(File)
      File.exist?(file).should be_true
      path_should_be_valid(file.path)

      info[:id].should be_eql(user.id)
      info[:category].should be_eql(category)
      info[:filename].should be_eql(filename)
    end

    it 'ブロックを与えられたとき、Fileオブジェクトとファイル情報をブロックに渡すこと' do
      subject.create(category, filename) do |file, info|
        file.should be_a(File)
        File.exist?(file).should be_true
        path_should_be_valid(file.path)

        info[:id].should be_eql(user.id)
        info[:category].should be_eql(category)
        info[:filename].should be_eql(filename)
      end
    end

    it '未知のカテゴリを受け入れないこと' do
      lambda {
        subject.create(:foo, filename)
      }.should raise_exception(ArgumentError)
    end

    it '不適切をファイル名を受け入れないこと' do
      lambda {
        subject.create(category, 'invalid/name.pdf')
      }.should raise_exception(ArgumentError)

      lambda {
        subject.create(category, 'invalid%name.pdf')
      }.should raise_exception(ArgumentError)

      lambda {
        subject.create(category, 'invalid,name.pdf')
      }.should raise_exception(ArgumentError)
    end
  end

  describe '#findは' do
    subject { UserFile.new(user) }

    before do
      @path, @info = subject.create(category, filename)
    end

    it '指定されたカテゴリ、ファイル名のファイルがあればそのパス名を返すこと' do
      path = subject.find(category, filename)
      path.should be_present
      path.should have(1).item
      path_should_be_valid(path.first)
      path.first.should == @path.path
    end

    it '指定されたカテゴリ、ファイル名、ランダム文字列のファイルがあればそのパス名を返すこと' do
      path2, info2 = subject.create(category, filename)
      path3, info3 = subject.create(category, filename)

      path = subject.find(category, filename, info3[:random])
      path.should be_present
      path.should have(1).items
      path.first.should == path3.path
    end

    it '複数ファイルが見付かったらmtimeでソートすること' do
      file2, = subject.create(category, filename)
      time = Time.now + 10.seconds
      File.utime(time, time, file2)

      path = subject.find(category, filename)
      path.should have(2).items
      path.last.should == file2.path
    end

    it '指定されたカテゴリ、ファイル名に対応するファイがなければ[]を返すこと' do
      path = subject.find(category, filename.reverse)
      path.should be_empty
    end

    it '不適切なカテゴリを指定されたら[]を返すこと' do
      path = subject.find(:unknown, filename)
      path.should be_empty
    end

    it '不適切なファイル名を指定されたら[]を返すこと' do
      path = subject.find(category, 'invalid,name.pdf')
      path.should be_empty
    end

    it '他のユーザのためのファイルを返さないこと' do
      user2 = mock_model(User, id: user.id + 1)
      user_file2 = UserFile.new(user2)
      user_file2.create(category, filename)

      path = subject.find(category, filename)
      path_should_be_valid(path.first)

      path = user_file2.find(category, filename)
      path_should_be_valid(path.first, user2)
    end
  end

  describe '.cleanup!は' do
    before do
      @save_category = UserFile.category
      UserFile.category = {
        foo: {expire: 10.minutes},
        bar: {expire: 30.minutes},
      }

      @files = []

      user_file = UserFile.new(user)
      @files << user_file.create(:foo, 'test1').first
      @files << user_file.create(:foo, 'test2').first
      @files << user_file.create(:bar, 'test1').first
      @files << user_file.create(:bar, 'test2').first

      user2 = mock_model(User, id: user.id + 1)
      user_file2 = UserFile.new(user2)
      @files << user_file2.create(:foo, 'test1').first
      @files << user_file2.create(:foo, 'test2').first
    end

    after do
      UserFile.category = @save_category
    end

    it '期限切れのファイルを削除すること' do
      UserFile.cleanup!
      @files.all? {|f| File.exist?(f.path) }.should be_true

      time = Time.now + 40.minutes
      touched_files = [@files[1], @files[3], @files[4]]
      File.utime(time, time, *touched_files)

      UserFile.cleanup!
      (@files - touched_files).all? {|f| File.exist?(f.path) }.should be_true
      touched_files.all? {|f| !File.exist?(f.path) }.should be_true
    end
  end

  describe '.check_filename!は' do
    it '不適切なファイル名を受け入れないこと' do
      lambda {
        UserFile.check_filename!('foo/../../../bar')
      }.should raise_exception(ArgumentError)
    end
  end
end
