# claude-rules — 全プロジェクト共通の Claude Code の規則

C:\Projects 配下のどのプロジェクトでも効く、Claude Code 用の規則の正本（2026-10-06 に作った）。
リモート＝GitHub の `NJ163/claude-rules`（**公開**・2026-10-10 に切り替え＝クラウドのセッションが取りに来るため。それまでの履歴は非公開の `NJ163/claude-rules-old` に保管）。
**公開＝誰でも読める＝どのプロジェクトにも効く作業の規則だけを書く**（事務所・顧客に関わることは各プロジェクトへ）。コミットの作成者はこのリポの設定で GitHub の匿名アドレス（noreply）にしてある。
ここを直せば、全プロジェクトの次の会話から効く。各プロジェクトへは写さない。

| ファイル | 中身 |
|---|---|
| `CLAUDE.md` | サブエージェントの使い分け・実装の後の手順（`/code-review` の level の選び方） |
| `agents/coder.md` | 実装担当サブエージェント（effort high）。規則の本文はここだけ |
| `agents/coder-medium.md`・`agents/coder-xhigh.md` | effort 違い。本文は「coder.md を読め」だけ |
| `prompts/プロジェクトを共通規則に合わせる.txt` | 各プロジェクトを共通規則に合わせる（と AGENTS.md 化する）ためのプロンプト |
| `cloud/setup.sh` | クラウドの環境の初期化スクリプト（下の「クラウド」） |

Codex など Claude Code 以外のエージェントには見えない（coder 系も `/code-review` も Claude Code 専用なので困らない）。
全エージェントに効かせたい規則は、各プロジェクトの AGENTS.md に書く。

## つなぎ方（Claude Code が自分から読むのはホームの `.claude` だけ）

- `C:\Users\owner\.claude\CLAUDE.md` ＝ `@C:/Projects/shared/claude-rules/CLAUDE.md` の1行だけ（取り込み）。
- `C:\Users\owner\.claude\agents` ＝ このフォルダの `agents` を指す**ジャンクション**（管理者権限不要）。

**このフォルダを動かす・名前を変えると、エラーにならずに規則が読まれなくなる**。動かしたら上の2つを付け直す。

### 新しいPC（事務所のサーバなど）で付け直す

PowerShell で（既に `agents` フォルダがあれば、中身を退避してから消す）：

```
New-Item -ItemType Junction -Path "$env:USERPROFILE\.claude\agents" -Target "C:\Projects\shared\claude-rules\agents"
```

`%USERPROFILE%\.claude\CLAUDE.md` に `@C:/Projects/shared/claude-rules/CLAUDE.md` の1行を書く（既にあれば先頭に足す）。
`agents` の中の `C:\Projects\shared\claude-rules\agents\coder.md` という絶対パスも、置き場所が変わるなら直す。

### 効いているかの確かめ方

適当なプロジェクトのフォルダで：

```
claude -p "Agent ツールで使えるサブエージェントの種類の名前だけを1行に1つ列挙して" --model haiku
```

`coder`・`coder-medium`・`coder-xhigh` が出れば効いている。

## クラウド（claude.ai/code）＝環境の初期化スクリプトで取ってくる（2026-10-10）

クラウドのセッションが読むのは作業するリポジトリの中身だけ＝このPCのホームの `.claude`（上のつなぎ方）もプラグインも読まれない。
代わりに、claude.ai/code の**環境の設定の「初期化スクリプト」**に `cloud/setup.sh` の中身を貼る。スクリプトがこのリポの公開ファイル（raw.githubusercontent.com）から `CLAUDE.md` と `agents/*.md` を取り、クラウドのホームの `~/.claude/` に置く＝**各プロジェクトのリポには何も足さない**。
出典＝公式 https://code.claude.com/docs/en/cloud-environments の「Add personal preferences without committing to the repo」（初期化スクリプトで `~/.claude/CLAUDE.md` を書けば読まれる）。`~/.claude/agents/` が読まれるかは資料に無い＝試し打ちで確かめる（読まれなければ親が実装する＝CLAUDE.md）。

- **反映の遅れ**：初期化スクリプトの結果はスナップショットで使い回され、作り直すのは「スクリプトの文面を変えた／許可する通信先を変えた／約7日の期限」のときだけ。再開したセッションには届かない（規則は開始時に読み込まれる）。
- **更新の手順**：直す → コミット → push → **5分ほど待つ**（raw.githubusercontent.com の反映待ち）→ 環境のスクリプトの先頭の `# rules 日付` を書き換えて保存（`cloud/setup.sh` も同じに直してコミット）→ 次の**新しい**セッションから効く。
  - 日付の書き換えは、ローカルの Claude Code が Chrome 拡張（claude-in-chrome）で行ってよい（2026-10-10 ユーザー）。入口＝claude.ai/code の入力欄の上の雲のボタン → Cloud の Default にマウスを乗せて出る歯車 → Setup script。**保存の前にユーザーの了承を得る**（アカウントの設定の変更のため）。
- **確かめ方**：クラウドのセッションで `/context` に `~/.claude/CLAUDE.md` が出て、先頭に「共通規則 … を 日時 JST に取得」とあること。取得に失敗すると「共通規則を読み込めていない」という1行だけが置かれる（日付を書き換えれば取り直す）。`/agents` に coder 系が出るか。
- 環境が複数あれば、それぞれに貼る。環境の通信の設定は既定の許可先（Trusted）を含むものにする。

## 注意

- プロジェクトの `.claude/agents/` に同じ名前（coder など）を作らない＝そちらが優先され、ここの更新が届かなくなる。
- 書き換えたら NUL や制御文字が無いことを確かめる（`tr -cd '\000\010' < ファイル | wc -c` が 0）。シェルの sed／Python でバックスラッシュを含むパスを書かない（`\a`・`\00` などが制御文字に化ける）＝Edit ツールで直す。
