const Hooks = {}

Hooks.CounterAnimation = {
  mounted() {
    const targetValue = parseInt(this.el.dataset.value) || 0
    const element = this.el.querySelector('#budget-amount')
    if (!element) return

    let currentValue = 0
    const increment = Math.ceil(targetValue / 100)
    const timer = setInterval(() => {
      currentValue += increment
      if (currentValue >= targetValue) {
        currentValue = targetValue
        clearInterval(timer)
      }
      const cents = currentValue
      const dollars = Math.floor(cents / 100)
      const remainingCents = cents % 100
      element.textContent = `$${dollars.toLocaleString()}.${remainingCents.toString().padStart(2, '0')}`
    }, 20)
  }
}

Hooks.TooltipHover = {
  mounted() {
    let tooltip = null
    
    this.el.addEventListener('mouseenter', (e) => {
      const message = this.el.dataset.tooltip
      if (!message) return

      tooltip = document.createElement('div')
      tooltip.className = 'absolute z-50 px-3 py-2 text-sm bg-gray-900 text-white rounded-lg shadow-lg pointer-events-none'
      tooltip.style.bottom = '100%'
      tooltip.style.left = '50%'
      tooltip.style.transform = 'translateX(-50%) translateY(-8px)'
      tooltip.style.whiteSpace = 'nowrap'
      tooltip.textContent = message
      
      const arrow = document.createElement('div')
      arrow.className = 'absolute top-full left-1/2 transform -translate-x-1/2'
      arrow.style.width = '0'
      arrow.style.height = '0'
      arrow.style.borderLeft = '4px solid transparent'
      arrow.style.borderRight = '4px solid transparent'
      arrow.style.borderTop = '4px solid #111827'
      tooltip.appendChild(arrow)
      
      this.el.style.position = 'relative'
      this.el.appendChild(tooltip)
      
      tooltip.style.opacity = '0'
      tooltip.style.transform = 'translateX(-50%) translateY(-4px)'
      setTimeout(() => {
        tooltip.style.opacity = '1'
        tooltip.style.transform = 'translateX(-50%) translateY(-8px)'
        tooltip.style.transition = 'all 0.2s ease-out'
      }, 10)
    })
    
    this.el.addEventListener('mouseleave', () => {
      if (tooltip) {
        tooltip.style.opacity = '0'
        tooltip.style.transform = 'translateX(-50%) translateY(-4px)'
        setTimeout(() => {
          if (tooltip && tooltip.parentNode) {
            tooltip.parentNode.removeChild(tooltip)
          }
          tooltip = null
        }, 200)
      }
    })
  }
}

Hooks.ProgressAnimation = {
  mounted() {
    const progressBar = this.el.querySelector('.progress-fill')
    if (!progressBar) return

    const targetPercentage = parseFloat(this.el.dataset.percentage) || 0
    const maxWidth = Math.min(targetPercentage, 100)
    
    progressBar.style.width = '0%'
    progressBar.style.transition = 'none'
    
    setTimeout(() => {
      progressBar.style.transition = 'width 1.5s ease-out'
      progressBar.style.width = `${maxWidth}%`
    }, 100)

    this.el.addEventListener('click', () => {
      this.el.style.transform = 'scale(0.98)'
      setTimeout(() => {
        this.el.style.transform = 'scale(1)'
        this.el.style.transition = 'transform 0.1s ease-out'
      }, 100)
    })
  },
  
  updated() {
    const progressBar = this.el.querySelector('.progress-fill')
    if (!progressBar) return

    const targetPercentage = parseFloat(this.el.dataset.percentage) || 0
    const maxWidth = Math.min(targetPercentage, 100)
    
    progressBar.style.width = `${maxWidth}%`
  }
}

export default Hooks