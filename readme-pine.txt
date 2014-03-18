make_rooted_system type-pine

基本的な仕組みはrara7886さんによるmake_rooted_system-rara7886を参考
	https://github.com/rara7886/make_rooted_system-rara7886

対象機種
	SC-01F(Galaxy Note3 docomo, Japan model)
		操作確認済み (ファーム:SC01FOMUBNB3・felica使用可・knox warranty voidは0を維持)
	SCL22や他国版Galaxy Note3でもおそらく使える

必要ファイル
	純正ファームウェアのsystem.img.ext4とcache.img.ext4

特記事項(基本的な使い方はreadme.txtを参照)
	suのバイナリは端末にインストール済みのSuperSUのapkから取得するので
	odinイメージを焼く前にPlayストアからSuperSUをインストールする必要がある

特徴
	============== Thanks to rara7886 ===========================
	1.起動時Scanを回避（初回起動時SysScope.apkを削除）
		・常時root化OK、Felica有効、SystemStatus(download modeで)がOfficial
		になるので、起動時にroot権限を必要とするアプリが使えます。
		・弊害として設定アプリ>一般>ステータス>端末状態がカスタム(起動2分後)になりますが、
		KNOX WARRANTRY BITがカウントアップしないので心配ありません。
		元々、カウントアップしてる人は、関係ありません。

		※改変boot.img,recovery.imgを焼いた場合は、カウントアップし、Felicaが無効になります。
		保障が必要な方は、注意してください。

	2. mountの罠について
		初回起動時　/system/bin/mount　をスクリプト化して、busyboxとtoolboxで使い分けるように対策

	3. init.dスクリプトに対応。

	============== 独自仕様 =====================================
	4.root化の方法について
		・初回起動(root未取得状態での起動)時にsuのバイナリを
		端末にインストールされているSuperSUのapkから取得して配置する

		・次回の起動からはroot取得状態であればバイナリの再配置は行わない
		そのためSuperSUアプリ内の操作でスーパーユーザーを無効化した状態で再起動しても
		勝手に有効化はしない(アプリ内の操作で再有効化は可能)

		・SuperSUの更新後はSuperSUアプリ内でのバイナリ更新のみで問題ないはず

