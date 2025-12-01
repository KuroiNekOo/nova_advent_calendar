// État du calendrier
let openedDays = [];
let currentDay = 1;
let calendarOpen = false;
let giftAnimationOpen = false;
let isGiftOpened = false;
let isProcessingDay = false; // Protection contre les double-clics

// Éléments DOM
const calendarContainer = document.getElementById('calendar-container');
const giftContainer = document.getElementById('gift-container');
const giftBox = document.getElementById('giftBox');
const giftBoxContainer = document.getElementById('giftBoxContainer');
const instruction = document.getElementById('instruction');

// Générer les rubans au chargement
function createRibbons() {
  const lidWrapper = document.getElementById('lidWrapper');

  // Créer 40 rubans gauche
  for (let i = 0; i <= 40; i++) {
    const ribbon = document.createElement('div');
    ribbon.className = 'ribbon-l';
    ribbon.style.setProperty('--gift-box-position', `${i}px`);

    // Bordure selon la position
    if (i <= 2 || i >= 38) {
      ribbon.style.borderColor = 'var(--gift-box-edge-color)';
    } else {
      ribbon.style.borderColor = 'var(--wrap-ribbon-color)';
    }

    lidWrapper.appendChild(ribbon);
  }

  // Ajouter l'extrémité gauche
  const ribbonLEnd = document.createElement('div');
  ribbonLEnd.className = 'ribbon-l-end';
  lidWrapper.appendChild(ribbonLEnd);

  // Créer 40 rubans droit
  for (let i = 0; i <= 40; i++) {
    const ribbon = document.createElement('div');
    ribbon.className = 'ribbon-r';
    ribbon.style.setProperty('--gift-box-position', `${i}px`);

    // Bordure selon la position
    if (i <= 2 || i >= 38) {
      ribbon.style.borderColor = 'var(--gift-box-edge-color)';
    } else {
      ribbon.style.borderColor = 'var(--wrap-ribbon-color)';
    }

    lidWrapper.appendChild(ribbon);
  }

  // Ajouter l'extrémité droite
  const ribbonREnd = document.createElement('div');
  ribbonREnd.className = 'ribbon-r-end';
  lidWrapper.appendChild(ribbonREnd);
}

createRibbons();

// Créer les flocons de neige
function createSnowflakes() {
  const snowflakesContainer = document.getElementById('snowflakes');
  const snowflakeSymbols = ['❅', '❆', '❄'];

  for (let i = 0; i < 50; i++) {
    const snowflake = document.createElement('div');
    snowflake.classList.add('snowflake');
    snowflake.textContent = snowflakeSymbols[Math.floor(Math.random() * snowflakeSymbols.length)];
    snowflake.style.left = Math.random() * 100 + '%';
    snowflake.style.animationDuration = (Math.random() * 3 + 2) + 's';
    snowflake.style.animationDelay = Math.random() * 5 + 's';
    snowflake.style.fontSize = (Math.random() * 1 + 0.5) + 'em';
    snowflakesContainer.appendChild(snowflake);
  }
}

createSnowflakes();

// Écouter les messages de FiveM
window.addEventListener('message', function(event) {
  const data = event.data;

  switch(data.action) {
    case 'openCalendar':
      openCalendar(data);
      break;
    case 'closeCalendar':
      closeCalendar();
      break;
    case 'showGift':
      showGift();
      break;
    case 'closeGift':
      closeGift();
      break;
    case 'updateDay':
      updateDayState(data.day, data.state);
      break;
  }
});

// Ouvrir le calendrier
function openCalendar(data) {
  openedDays = data.openedDays || [];
  currentDay = data.currentDay || 1;
  calendarOpen = true;

  calendarContainer.classList.add('visible');
  initializeCalendar();
}

// Initialiser le calendrier avec les états des cases
function initializeCalendar() {
  const dayDoors = document.querySelectorAll('.day-door');

  dayDoors.forEach(door => {
    const day = parseInt(door.parentElement.getAttribute('data-day'));
    const state = getDayState(day);
    applyDayStyle(door, state, day);

    // Ajouter l'event listener
    door.addEventListener('click', function() {
      handleDayClick(day);
    });
  });
}

// Déterminer l'état d'un jour
function getDayState(day) {
  if (openedDays.includes(day)) return 'opened';
  if (day === currentDay) return 'current';
  if (day < currentDay) return 'missed';
  if (day > currentDay) return 'locked';
  return 'locked';
}

// Appliquer le style selon l'état
function applyDayStyle(doorElement, state, day) {
  doorElement.classList.remove('opened', 'missed', 'locked', 'current');

  switch(state) {
    case 'opened':
      doorElement.classList.add('opened');
      doorElement.style.background = 'rgba(34, 139, 34, 0.7)';
      doorElement.style.borderColor = 'rgba(0, 100, 0, 1)';
      doorElement.style.color = '#ffffff';
      doorElement.style.cursor = 'not-allowed';
      doorElement.style.boxShadow = 'none';
      doorElement.innerHTML = day + ' ✓';
      break;

    case 'missed':
      doorElement.classList.add('missed');
      doorElement.style.background = 'rgba(220, 38, 38, 0.7)';
      doorElement.style.borderColor = 'rgba(153, 27, 27, 1)';
      doorElement.style.color = '#ffffff';
      doorElement.style.cursor = 'not-allowed';
      doorElement.style.boxShadow = 'none';
      doorElement.innerHTML = day + ' ✗';
      break;

    case 'locked':
      doorElement.classList.add('locked');
      doorElement.style.background = 'rgba(107, 114, 128, 0.5)';
      doorElement.style.borderColor = 'rgba(75, 85, 99, 0.7)';
      doorElement.style.color = '#9CA3AF';
      doorElement.style.cursor = 'not-allowed';
      doorElement.style.boxShadow = 'none';
      doorElement.innerHTML = day + ' 🔒';
      break;

    case 'current':
      doorElement.classList.add('current');
      doorElement.style.background = 'rgba(173, 216, 230, 0.7)';
      doorElement.style.borderColor = 'rgba(255, 215, 0, 0.8)';
      doorElement.style.color = '#1a5f7a';
      doorElement.style.cursor = 'pointer';
      doorElement.innerHTML = day + ' 🎁';
      break;
  }
}

// Gérer le clic sur une case
function handleDayClick(day) {
  const state = getDayState(day);

  if (state !== 'current') {
    return;
  }

  // Protection contre les double-clics
  if (isProcessingDay) {
    console.log('[Calendar] Traitement en cours, veuillez patienter...');
    return;
  }

  isProcessingDay = true;

  // Envoyer la requête à FiveM
  fetch(`https://esx_advent_calendar/openDay`, {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json'
    },
    body: JSON.stringify({ day: day })
  })
  .then(resp => resp.json())
  .then(data => {
    if (!data.success) {
      console.log('[Calendar] Échec de l\'ouverture:', data.reason);
      // Réinitialiser le flag en cas d'échec
      isProcessingDay = false;
    }
    // Si succès, le flag sera réinitialisé à la fermeture du calendrier
  })
  .catch(err => {
    console.error('[Calendar] Erreur:', err);
    // Réinitialiser le flag en cas d'erreur
    isProcessingDay = false;
  });
}

// Mettre à jour l'état d'un jour
function updateDayState(day, state) {
  if (state === 'opened') {
    if (!openedDays.includes(day)) {
      openedDays.push(day);
    }
  }

  const doorElement = document.querySelector(`.day-item[data-day="${day}"] .day-door`);
  if (doorElement) {
    applyDayStyle(doorElement, state, day);
  }
}

// Afficher l'animation du cadeau
function showGift() {
  giftAnimationOpen = true;
  isGiftOpened = false;
  giftContainer.classList.add('visible');

  // Réinitialiser toutes les classes d'animation
  giftBox.classList.remove('opened', 'paused', 'rotating-to-open');
  giftBoxContainer.classList.remove('shake', 'loaded');
  instruction.classList.remove('hidden');

  // Forcer le reflow pour relancer l'animation popIn
  void giftBoxContainer.offsetWidth;

  // Fixer l'apparence du cadeau après l'animation initiale (0.2s délai + 0.4s animation = 0.6s)
  setTimeout(() => {
    giftBoxContainer.classList.add('loaded');
  }, 600);

  // NE PAS ouvrir automatiquement - le joueur doit cliquer
}

// Animation d'ouverture du cadeau
function openGiftAnimation() {
  // Arrêter la rotation immédiatement
  giftBox.classList.add('paused');

  // Masquer l'instruction immédiatement
  instruction.classList.add('hidden');

  // Rotation vers l'angle optimal
  giftBox.classList.add('rotating-to-open');

  setTimeout(() => {
    // Animation de tremblement
    giftBoxContainer.classList.add('shake');

    setTimeout(() => {
      // Ouvrir le cadeau
      giftBox.classList.add('opened');

      // Créer des confettis
      setTimeout(() => {
        createConfetti();

        // Notifier le client Lua que le cadeau est complètement ouvert
        // C'est ici que le CloseDelay doit commencer
        fetch(`https://esx_advent_calendar/giftFullyOpened`, {
          method: 'POST',
          headers: {
            'Content-Type': 'application/json'
          },
          body: JSON.stringify({})
        }).catch(err => {
          console.log('[Calendar] Erreur fetch giftFullyOpened:', err);
        });
      }, 1500);

      giftBoxContainer.classList.remove('shake');
    }, 500);
  }, 1000);
}

// Clic sur le cadeau pour l'ouvrir
giftBoxContainer.addEventListener('click', function() {
  if (giftAnimationOpen && !isGiftOpened) {
    isGiftOpened = true;
    openGiftAnimation();
  }
});

// Créer des confettis
function createConfetti() {
  const colors = ['#ff0000', '#00ff00', '#0000ff', '#ffff00', '#ff00ff', '#00ffff', '#ffa500'];

  for (let i = 0; i < 50; i++) {
    const confetti = document.createElement('div');
    confetti.className = 'confetti';
    confetti.style.left = Math.random() * 100 + '%';
    confetti.style.top = '-10px';
    confetti.style.backgroundColor = colors[Math.floor(Math.random() * colors.length)];
    confetti.style.animation = `confetti-fall ${2 + Math.random() * 2}s ease-out forwards`;
    confetti.style.animationDelay = Math.random() * 0.5 + 's';
    document.body.appendChild(confetti);

    setTimeout(() => confetti.remove(), 4000);
  }
}

// Fermer l'animation du cadeau
function closeGift() {
  giftAnimationOpen = false;
  giftContainer.classList.remove('visible');
}

// Fermer le calendrier
function closeCalendar() {
  calendarOpen = false;
  calendarContainer.classList.remove('visible');
  giftContainer.classList.remove('visible');
  // Réinitialiser le flag de traitement
  isProcessingDay = false;
}

// Gérer la touche ESC
document.addEventListener('keydown', function(e) {
  if (e.key === 'Escape' || e.keyCode === 27) {
    if (calendarOpen && !giftAnimationOpen) {
      fetch(`https://esx_advent_calendar/closeCalendar`, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json'
        },
        body: JSON.stringify({})
      }).catch(err => {
        console.log('[Calendar] Erreur fetch:', err);
      });
    }
  }
});
