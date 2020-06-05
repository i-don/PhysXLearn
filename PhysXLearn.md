# PhysXの勉強
PhysXをWindows10で試してみる  
### 道具立て（ソフト）  
2020年3月時点で最新な感じ
- PhysX  4.1
- Microsoft Visual Studio Community 2019
- DirectX Software Development Kit Version9.29.1962
- python-3.8.2
- CMake 3.17.0
- PhysX Visual Debugger Version 3.2019.04.26214843

### 道具立て（ハード）
- ASRock H97 Pro4
- NE6206S018P2-1160A (GeForce RTX2060 SUPER DUAL 8GB) [PCIExp 8GB] ドスパラWeb限定モデル

### 道具の導入
1. PhysXの取得  
githubからクローンを作成  
リポジトリは<https://github.com/NVIDIAGameWorks/PhysX.git>  
2. Visual Studioインストール  
ダウンロードしてインストール  
インストール時はC++を選択する  
ダウンロード元は<https://visualstudio.microsoft.com/ja/thank-you-downloading-visual-studio/?sku=Community&rel=16>  
3. DirectX SDKインストール  
ダウンロードしてインストール  
ダウンロード元は<https://www.microsoft.com/en-us/download/details.aspx?displaylang=en&id=6812>  
4. pythonインストール  
64bit版をダウンロードしてインストール  
Pathの追加をチェックする  
ダウンロード元は<https://www.python.org/downloads/>  
5. CMakeインストール  
64bit版をダウンロードしてインストール  
Pathの追加をチェックする  
ダウンロード元は<https://cmake.org/download/>  
6. PhysX Visual Debuggerインストール  
ダウンロードしてインストール  
ダウンロードにはNVIDIA accountの登録が必要  
ダウンロード元は<https://developer.nvidia.com/physx-visual-debugger>  

### PhysXのビルド
1. プロジェクトの生成  
PhysXのクローン内にある physx\generate_projects.bat を実行する  
vc16win64を選択するために13を入力する  
2. コード修正１  
physx\source\foundation\include\PsAllocator.h を修正  
エラーがモリモリ出るから  
なぜならVisual Studio2019の標準準拠強化でtypeinfo.hが削除されたから  
```C++:PsAllocator.h
  #if(PX_WINDOWS_FAMILY || PX_XBOXONE)
      #include <exception>
  -  #include <typeinfo.h>
  +  #if(_MSC_VER >= 1923)
  +      #include <typeinfo>
  +  #else
  +      #include <typeinfo.h>
  +  #endif
  #endif
```
3. コード修正２  
physx\samples\sampleframework\renderer\src\d3d11\D3D11RendererMemoryMacros.h を修正  
エラーにならないように誤魔化す  
deleteAllとdxSafeReleaseAllにnopを経由させる  
```C++:D3D11RendererMemoryMacros.h
   template<class T>
  -  PX_INLINE void deleteAll( T& t ) { std::remove_if(t.begin(), t.end(), deleteAndReturnTrue<typename T::value_type>); };
  +  PX_INLINE void nop(T t) { };
  +  
  +  template<class T>
  -  PX_INLINE void dxSafeReleaseAll( T& t ) { std::remove_if(t.begin(), t.end(), dxReleaseAndReturnTrue<typename T::value_type>); };
  +  PX_INLINE void deleteAll( T& t ) { nop(std::remove_if(t.begin(), t.end(), deleteAndReturnTrue<typename T::value_type>)); };
  +  
  +  template<class T>
  +  PX_INLINE void dxSafeReleaseAll( T& t ) { nop(std::remove_if(t.begin(), t.end(), dxReleaseAndReturnTrue<typename T::value_type>)); };
```  
4. コード修正３  
physx\samples\sampleframework\renderer\src\d3d11\D3D11RendererResourceManager.h を修正  
チェックが厳しくてエラーになるのでデストラクタ追加  
```C++:D3D11RendererResourceManager.h
    class Proxy
    {
    public:
        virtual const std::type_info& type_info() const = 0;
        virtual Proxy *clone() const = 0;
        virtual void release() = 0;
  +    virtual ~Proxy() {}
```  
5. ビルド  
PhysXのクローン内にある physx\compiler\vc16win64\PhysXSDK.sln  
をVisual Studioで開く  
release構成を選んでソリューションをリビルドする  

### サンプルプログラムkaplademoのビルドと実行
1. ソリューションのコピー  
Visual Studio 2019用のソリューションがないので2017用をコピー  
PhysXのクローン内にある kaplademo\source\compiler\vc15win64-PhysX_4.1 フォルダを  
kaplademo\source\compiler\vc16win64-PhysX_4.1 にコピーする  
2. ソリューションの再ターゲット  
kaplademo\source\compiler\vc16win64-PhysX_4.1\KaplaDemo.sln  
をVisual Studioで開く  
ソリューション操作の再ターゲット ダイアログが表示されるので OKボタンで再ターゲットを実行  
3. release構成を選ぶ  
4. DemoFrameworkプロジェクトのプロパティ変更  
	- 全般-出力ディレクトリ  
./../../../bin/VC1***6***WIN64/RELEASE\  
5. KaplaDemoプロジェクトのプロパティ変更  
	- 全般-出力ディレクトリ  
./../../../bin/VC1***6***WIN64/RELEASE\  
	- リンカー-追加のライブラリ ディレクトリ  
./../../../../physx/bin/win.x86_64.vc14***2***.mt/$(ConfigurationName)  
./../../../externals/glew-1.13.0/lib/WIN64  
./../../../externals/glut-3.7.6/lib/WIN64  
./../../../externals/hbao+3.0/lib/WIN64  
./../../../externals/cg/2.2/lib.x64  
./../../../lib/VC1***6***WIN64  
./../../../lib  
	- リンカー-詳細設定-インポート ライブラリ  
./../../../lib/VC1***6***WIN64/RELEASE/$(TargetName).lib  
	- ビルド イベント-ビルド後のイベント-コマンドライン  
..\physx64copy.bat ./../../../../physx/bin/win.x86_64.vc14***2***.mt ..\..\..\bin\VC1***6***WIN64 ../../../externals ../../../externals/glut-3.7.6/bin/WIN64 ../../../externals/cg/2.2/bin.x64 ../../../externals/hbao+3.0/lib/WIN64 -postbuildevent  
6. ビルド  
7. kaplademo実行  
kaplademo\bin\VC16WIN64\RELEASE\KaplaDemo.exe  
を実行して、PhysXとkaplademoが正しくビルドできていることを確認する  

### PhysX Visual Debugger(PVD)使用の準備
1. PhysXをcheckedビルド  
PhysXのクローン内にある physx\compiler\vc16win64\PhysXSDK.sln  
をVisual Studioで開く  
checked構成を選んでソリューションをリビルドする  
2. デバッグ対象のプロジェクト作成  
Visual Studioで新規プロジェクトを作成する  
テンプレートは　Windowsデスクトップアプリケーションとする  
プロジェクトの構成（すべての構成）は次のように修正  

|||プロパティ|値|
|:-----|:-----|:-----|:-----|
|C/C++|全般|追加のインクルードディレクトリ|(PhysXのクローン)\physx\include;(PhysXのクローン)\pxshared\include;(PhysXのクローン)\physx\source\common\src;(PhysXのクローン)\physx\source\foundation\include;(PhysXのクローン)\physx\snippets;(PhysXのクローン)\physx\snippets\graphics\include\win32\GL;%(AdditionalIncludeDirectories)|
|リンカー|入力|追加の依存ファイル|(PhysXのクローン)\physx\bin\win.x86_64.vc142.mt\$(Configuration)\PhysXExtensions_static_64.lib;(PhysXのクローン)\physx\bin\win.x86_64.vc142.mt\$(Configuration)\PhysX_64.lib;(PhysXのクローン)\physx\bin\win.x86_64.vc142.mt\$(Configuration)\PhysXPvdSDK_static_64.lib;(PhysXのクローン)\physx\bin\win.x86_64.vc142.mt\$(Configuration)\PhysXVehicle_static_64.lib;(PhysXのクローン)\physx\bin\win.x86_64.vc142.mt\$(Configuration)\PhysXCharacterKinematic_static_64.lib;(PhysXのクローン)\physx\bin\win.x86_64.vc142.mt\$(Configuration)\PhysXCooking_64.lib;(PhysXのクローン)\physx\bin\win.x86_64.vc142.mt\$(Configuration)\PhysXCommon_64.lib;(PhysXのクローン)\physx\bin\win.x86_64.vc142.mt\$(Configuration)\PhysXFoundation_64.lib;(PhysXのクローン)\physx\bin\win.x86_64.vc142.mt\$(Configuration)\SnippetRender_static_64.lib;(PhysXのクローン)\physx\snippets\graphics\lib\win64\glut\glut32.lib;%(AdditionalDependencies)|

3. 構成の追加  
構成マネージャからデバッグ対象のプロジェクトに構成を追加する  
checkedをDebugを元に新規作成する  
プロジェクトの構成（checked）は次のように修正  

|||プロパティ|値|
|:-----|:-----|:-----|:-----|
|C/C++|コード生成|ランタイムライブラリ|/MT|
|C/C++|プリプロセッサ|プリプロセッサの定義|_HAS_ITERATOR_DEBUGGING=0;_ITERATOR_DEBUG_LEVEL=0;NDEBUG;WIN32;WIN64;_CRT_SECURE_NO_DEPRECATE;_CRT_NONSTDC_NO_DEPRECATE;_WINSOCK_DEPRECATED_NO_WARNINGS;RENDER_SNIPPET;PX_CHECKED=1;PX_NVTX=0;PX_SUPPORT_PVD=1;CMAKE_INTDIR="checked";%(PreprocessorDefinitions)|

### PhysX Visual Debugger(PVD)使用
1. PVD起動  
先にPVDを起動しておく
2. PVD接続用コードを書く  
デバッグ対象のプログラムにPVD接続用のコードを追加する  
PxPvdオブジェクトを宣言  
```C++
PxPvd* gPvd = NULL;
```
初期化時にPVDに接続  
PxPvdオブジェクトを生成し、PVDに接続、PxPhysics生成時に反映
```C++
	gPvd = PxCreatePvd(*gFoundation);
	PxPvdTransport* transport = PxDefaultPvdSocketTransportCreate(PVD_HOST, 5425, 10);
	gPvd->connect(*transport, PxPvdInstrumentationFlag::eALL);

	gPhysics = PxCreatePhysics(PX_PHYSICS_VERSION, *gFoundation, PxTolerancesScale(), true, gPvd);
```
終了時にオブジェクトを開放
```C++
	if (gPvd)
	{
		PxPvdTransport* transport = gPvd->getTransport();
		gPvd->release();	gPvd = NULL;
		PX_RELEASE(transport);
	}
```
3. 実行  
デバッグ対象のプログラムを実行する  
PVDにレンダリング結果が表示されれば接続できていることが確認できた  
デバッグ対象のプログラムを終了すると、PVDでProfile結果が確認できる  
