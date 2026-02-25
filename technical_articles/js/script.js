document.addEventListener('DOMContentLoaded', () => {
    // ==========================================
    // 1. コードブロックに「Copy」ボタンを追加
    // ==========================================
    const preElements = document.querySelectorAll('pre');
    preElements.forEach(pre => {
        // pre要素を相対位置にしてボタンを右上に配置できるようにする
        pre.style.position = 'relative';
        
        const copyBtn = document.createElement('button');
        copyBtn.innerText = 'Copy';
        copyBtn.className = 'copy-btn';
        pre.appendChild(copyBtn);

        copyBtn.addEventListener('click', () => {
            // pre内のテキストを取得（コピーボタン自身のテキストは除外する）
            const code = pre.querySelector('code');
            const textToCopy = code ? code.innerText : pre.innerText.replace('Copy', '');
            
            navigator.clipboard.writeText(textToCopy).then(() => {
                copyBtn.innerText = 'Copied!';
                copyBtn.classList.add('copied');
                
                // 2秒後に元の文字に戻す
                setTimeout(() => {
                    copyBtn.innerText = 'Copy';
                    copyBtn.classList.remove('copied');
                }, 2000);
            });
        });
    });

    // ==========================================
    // 2. 画像のクリック拡大機能（Lightbox）
    // ==========================================
    const images = document.querySelectorAll('.terminal-img');
    const lightbox = document.createElement('div');
    lightbox.id = 'lightbox';
    document.body.appendChild(lightbox);

    images.forEach(img => {
        img.title = "クリックで拡大表示";
        img.addEventListener('click', () => {
            lightbox.classList.add('active');
            const imgClone = document.createElement('img');
            imgClone.src = img.src;
            
            // 中身をリセットして追加
            while(lightbox.firstChild) {
                lightbox.removeChild(lightbox.firstChild);
            }
            lightbox.appendChild(imgClone);
        });
    });

    // 暗い背景をクリックしたら閉じる
    lightbox.addEventListener('click', () => {
        lightbox.classList.remove('active');
    });

    // ==========================================
    // 3. スクロール時の「目次の現在地ハイライト」
    // ==========================================
    const tocLinks = document.querySelectorAll('.toc a');
    const sections = Array.from(document.querySelectorAll('h2[id]'));
    
    // 画面の少し上部を判定基準にする
    const observerOptions = {
        root: null,
        rootMargin: '-10% 0px -80% 0px',
        threshold: 0
    };

    const observer = new IntersectionObserver(entries => {
        entries.forEach(entry => {
            if (entry.isIntersecting) {
                // すべてのアクティブを外す
                tocLinks.forEach(link => link.classList.remove('active'));
                
                // 現在のセクションに対応するリンクをアクティブにする
                const id = entry.target.getAttribute('id');
                const activeLink = document.querySelector(`.toc a[href="#${id}"]`);
                if (activeLink) {
                    activeLink.classList.add('active');
                }
            }
        });
    }, observerOptions);

    sections.forEach(section => observer.observe(section));

    // ==========================================
    // 4. 要素のフワッと表示（フェードインアニメーション）
    // ==========================================
    // アニメーションさせたい要素のクラスを指定
    const fadeElements = document.querySelectorAll('.step-box, .scenario, .visual-compare, .terminal-summary');
    
    const fadeObserver = new IntersectionObserver(entries => {
        entries.forEach(entry => {
            if (entry.isIntersecting) {
                entry.target.classList.add('fade-in-visible');
                fadeObserver.unobserve(entry.target); // 一度表示したら監視を終了
            }
        });
    }, { threshold: 0.1 });

    fadeElements.forEach(el => {
        el.classList.add('fade-in-hidden'); // 初期状態は非表示
        fadeObserver.observe(el);
    });
});