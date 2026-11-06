const paginaDefinirSenha = r'''<!DOCTYPE html>
<html lang="pt-BR">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>Definir senha · Gerenciador de Quadras</title>
<style>
  :root { --azul: #1565C0; --texto: #0D1B3E; --suave: #5A6475; --erro: #B3261E; --fundo: #EEF3FC; }
  * { box-sizing: border-box; }
  body { margin: 0; min-height: 100vh; display: grid; place-items: center; padding: 16px;
         background: var(--fundo); color: var(--texto); font-family: system-ui, -apple-system, "Segoe UI", Roboto, sans-serif; }
  main { width: 100%; max-width: 380px; background: #fff; border-radius: 16px; padding: 28px 24px;
         box-shadow: 0 8px 24px rgba(13, 27, 62, .08); }
  h1 { margin: 0 0 6px; font-size: 1.5rem; }
  p { margin: 0 0 20px; color: var(--suave); line-height: 1.4; }
  label { display: block; font-size: .85rem; color: var(--suave); margin: 14px 0 6px; }
  input { width: 100%; padding: 12px 14px; border: 1px solid #D5DBE5; border-radius: 10px; font-size: 1rem; }
  input:focus { outline: 2px solid var(--azul); border-color: transparent; }
  .erro-campo { color: var(--erro); font-size: .8rem; min-height: 1em; margin-top: 4px; }
  button { width: 100%; margin-top: 22px; padding: 13px; border: 0; border-radius: 10px; background: var(--azul);
           color: #fff; font-size: 1rem; font-weight: 600; cursor: pointer; }
  button:disabled { opacity: .6; cursor: default; }
  .aviso { margin-top: 16px; padding: 12px; border-radius: 10px; font-size: .9rem; }
  .aviso.erro { background: #FCEEEE; color: var(--erro); }
  .aviso.sucesso { background: #E8F5E9; color: #1B5E20; }
  [hidden] { display: none !important; }
</style>
</head>
<body>
<main>
  <h1>Definir senha</h1>
  <p>Escolha uma senha com pelo menos 8 caracteres para acessar o aplicativo.</p>
  <form id="formulario" novalidate>
    <label for="senha">Nova senha</label>
    <input id="senha" name="senha" type="password" autocomplete="new-password" required>
    <div class="erro-campo" id="erro-senha"></div>
    <label for="confirmarSenha">Confirmar senha</label>
    <input id="confirmarSenha" name="confirmarSenha" type="password" autocomplete="new-password" required>
    <div class="erro-campo" id="erro-confirmarSenha"></div>
    <button id="botao" type="submit">Salvar senha</button>
  </form>
  <div id="aviso" class="aviso" hidden></div>
</main>
<script>
  const token = new URLSearchParams(location.search).get('token');
  const formulario = document.getElementById('formulario');
  const botao = document.getElementById('botao');
  const aviso = document.getElementById('aviso');

  function mostrarAviso(texto, tipo) {
    aviso.textContent = texto;
    aviso.className = 'aviso ' + tipo;
    aviso.hidden = false;
  }

  function limparErros() {
    for (const campo of ['senha', 'confirmarSenha']) {
      document.getElementById('erro-' + campo).textContent = '';
    }
    aviso.hidden = true;
  }

  if (!token) {
    formulario.hidden = true;
    mostrarAviso('Link incompleto. Abra novamente o link recebido por email.', 'erro');
  }

  formulario.addEventListener('submit', async (evento) => {
    evento.preventDefault();
    limparErros();
    botao.disabled = true;
    try {
      const resposta = await fetch(location.pathname, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          token,
          senha: formulario.senha.value,
          confirmarSenha: formulario.confirmarSenha.value,
        }),
      });
      const corpo = await resposta.json().catch(() => ({}));
      if (resposta.ok) {
        formulario.hidden = true;
        mostrarAviso('Senha salva! Volte ao aplicativo e faça login.', 'sucesso');
        return;
      }
      const erro = corpo.erro || {};
      let errosExibidos = 0;
      for (const [campo, mensagem] of Object.entries(erro.campos || {})) {
        const alvo = document.getElementById('erro-' + campo);
        if (alvo) {
          alvo.textContent = mensagem;
          errosExibidos++;
        }
      }
      if (errosExibidos === 0) {
        mostrarAviso(erro.mensagem || 'Não foi possível salvar a senha.', 'erro');
      }
    } catch (_) {
      mostrarAviso('Sem conexão com o servidor. Tente novamente.', 'erro');
    } finally {
      botao.disabled = false;
    }
  });
</script>
</body>
</html>
''';
