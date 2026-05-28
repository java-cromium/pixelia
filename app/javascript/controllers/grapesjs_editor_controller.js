import { Controller } from "@hotwired/stimulus"
import grapesjs from "grapesjs"
import grapesjsPresetWebpage from "grapesjs-preset-webpage"
import grapesjsBlocksBasic from "grapesjs-blocks-basic"

export default class extends Controller {
  static targets = [
    "canvas", "saveStatus", "deviceButtons",
    "blocksPanel", "layersPanel", "stylesPanel",
    "selectorsPanel", "styleManagerPanel", "traitsPanel",
    "panelBtn"
  ]

  static values = {
    loadUrl: String,
    storeUrl: String,
    csrfToken: String
  }

  connect() {
    this.initEditor()
  }

  disconnect() {
    if (this.editor) {
      this.editor.destroy()
    }
  }

  initEditor() {
    const loadUrl = this.loadUrlValue
    const storeUrl = this.storeUrlValue
    const csrfToken = this.csrfTokenValue

    this.editor = grapesjs.init({
      container: this.canvasTarget,
      height: "100%",
      width: "auto",
      fromElement: false,

      plugins: [grapesjsBlocksBasic, grapesjsPresetWebpage],
      pluginsOpts: {
        [grapesjsBlocksBasic]: {
          flexGrid: true,
        },
        [grapesjsPresetWebpage]: {
          modalImportTitle: "Import Template",
          modalImportButton: "Import",
          modalImportLabel: '<div style="margin-bottom: 10px; font-size: 13px;">Paste your HTML/CSS here</div>',
        },
      },

      // Storage: wire to Rails API
      storageManager: {
        type: "remote",
        autosave: true,
        autoload: true,
        stepsBeforeSave: 1,
        options: {
          remote: {
            urlLoad: loadUrl,
            urlStore: storeUrl,
            fetchOptions: (opts) => ({
              ...opts,
              headers: {
                "Content-Type": "application/json",
                "X-CSRF-Token": csrfToken,
              },
            }),
            onStore: (data, editor) => {
              const pagesHtml = editor.Pages.getAll().map((page) => {
                const component = page.getMainComponent()
                return {
                  html: editor.getHtml({ component }),
                  css: editor.getCss({ component }),
                }
              })
              return { data, pagesHtml }
            },
            onLoad: (result) => result,
          },
        },
      },

      // Canvas styling
      canvas: {
        styles: [
          "https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700;800&display=swap",
        ],
      },

      // Device manager for responsive preview
      deviceManager: {
        devices: [
          { name: "Desktop", width: "" },
          { name: "Tablet", width: "768px", widthMedia: "992px" },
          { name: "Mobile", width: "375px", widthMedia: "480px" },
        ],
      },

      // Render blocks, layers, styles, traits in our custom panels
      blockManager: {
        appendTo: this.blocksPanelTarget,
      },
      layerManager: {
        appendTo: this.layersPanelTarget,
      },
      selectorManager: {
        appendTo: this.selectorsPanelTarget,
      },
      styleManager: {
        appendTo: this.styleManagerPanelTarget,
        sectors: [
          {
            name: "General",
            open: false,
            buildProps: ["float", "display", "position", "top", "right", "left", "bottom"],
          },
          {
            name: "Flex",
            open: false,
            buildProps: ["flex-direction", "flex-wrap", "justify-content", "align-items", "align-content", "order", "flex-basis", "flex-grow", "flex-shrink", "align-self"],
          },
          {
            name: "Dimension",
            open: false,
            buildProps: ["width", "height", "max-width", "min-height", "margin", "padding"],
          },
          {
            name: "Typography",
            open: false,
            buildProps: ["font-family", "font-size", "font-weight", "letter-spacing", "color", "line-height", "text-align", "text-decoration", "text-shadow"],
          },
          {
            name: "Decorations",
            open: false,
            buildProps: ["background-color", "border-radius", "border", "box-shadow", "background"],
          },
          {
            name: "Extra",
            open: false,
            buildProps: ["opacity", "transition", "transform", "cursor", "overflow"],
          },
        ],
      },
      traitManager: {
        appendTo: this.traitsPanelTarget,
      },

      // Disable default panels (we use our own UI)
      panels: { defaults: [] },
    })

    // Add custom blocks for website sections
    this.addCustomBlocks()

    // Listen for save events to update status indicator
    this.editor.on("storage:start:store", () => {
      this.saveStatusTarget.textContent = "Saving..."
      this.saveStatusTarget.classList.remove("text-slate-500", "text-red-400")
      this.saveStatusTarget.classList.add("text-amber-400")
    })

    this.editor.on("storage:end:store", () => {
      this.saveStatusTarget.textContent = "Saved"
      this.saveStatusTarget.classList.remove("text-amber-400", "text-red-400")
      this.saveStatusTarget.classList.add("text-slate-500")
    })

    this.editor.on("storage:error:store", () => {
      this.saveStatusTarget.textContent = "Save failed"
      this.saveStatusTarget.classList.remove("text-amber-400", "text-slate-500")
      this.saveStatusTarget.classList.add("text-red-400")
    })
  }

  addCustomBlocks() {
    const bm = this.editor.BlockManager

    bm.add("hero-section", {
      label: "Hero Section",
      category: "Sections",
      content: `
        <section style="padding: 80px 40px; text-align: center; background: linear-gradient(135deg, #0f172a, #1e293b);">
          <h1 style="font-size: 48px; font-weight: 800; color: #f8fafc; margin-bottom: 16px; font-family: Inter, sans-serif;">Your Headline Here</h1>
          <p style="font-size: 18px; color: #94a3b8; max-width: 600px; margin: 0 auto 32px; font-family: Inter, sans-serif;">A short description that captures attention and explains your value proposition.</p>
          <a href="#" style="display: inline-block; padding: 14px 32px; background: #6366f1; color: #fff; border-radius: 12px; text-decoration: none; font-weight: 600; font-family: Inter, sans-serif;">Get Started</a>
        </section>
      `,
    })

    bm.add("features-grid", {
      label: "Features Grid",
      category: "Sections",
      content: `
        <section style="padding: 60px 40px; background: #0f172a;">
          <h2 style="text-align: center; font-size: 32px; font-weight: 700; color: #f8fafc; margin-bottom: 48px; font-family: Inter, sans-serif;">Features</h2>
          <div style="display: flex; gap: 24px; flex-wrap: wrap; justify-content: center; max-width: 1000px; margin: 0 auto;">
            <div style="flex: 1; min-width: 250px; max-width: 300px; padding: 32px; background: #1e293b; border-radius: 16px; border: 1px solid #334155;">
              <div style="width: 48px; height: 48px; background: #6366f1; border-radius: 12px; margin-bottom: 16px;"></div>
              <h3 style="font-size: 18px; font-weight: 600; color: #f8fafc; margin-bottom: 8px; font-family: Inter, sans-serif;">Feature One</h3>
              <p style="font-size: 14px; color: #94a3b8; font-family: Inter, sans-serif;">Brief description of this feature and why it matters to your users.</p>
            </div>
            <div style="flex: 1; min-width: 250px; max-width: 300px; padding: 32px; background: #1e293b; border-radius: 16px; border: 1px solid #334155;">
              <div style="width: 48px; height: 48px; background: #06b6d4; border-radius: 12px; margin-bottom: 16px;"></div>
              <h3 style="font-size: 18px; font-weight: 600; color: #f8fafc; margin-bottom: 8px; font-family: Inter, sans-serif;">Feature Two</h3>
              <p style="font-size: 14px; color: #94a3b8; font-family: Inter, sans-serif;">Brief description of this feature and why it matters to your users.</p>
            </div>
            <div style="flex: 1; min-width: 250px; max-width: 300px; padding: 32px; background: #1e293b; border-radius: 16px; border: 1px solid #334155;">
              <div style="width: 48px; height: 48px; background: #10b981; border-radius: 12px; margin-bottom: 16px;"></div>
              <h3 style="font-size: 18px; font-weight: 600; color: #f8fafc; margin-bottom: 8px; font-family: Inter, sans-serif;">Feature Three</h3>
              <p style="font-size: 14px; color: #94a3b8; font-family: Inter, sans-serif;">Brief description of this feature and why it matters to your users.</p>
            </div>
          </div>
        </section>
      `,
    })

    bm.add("cta-section", {
      label: "Call to Action",
      category: "Sections",
      content: `
        <section style="padding: 60px 40px; text-align: center; background: linear-gradient(135deg, #4f46e5, #7c3aed);">
          <h2 style="font-size: 32px; font-weight: 700; color: #fff; margin-bottom: 12px; font-family: Inter, sans-serif;">Ready to Get Started?</h2>
          <p style="font-size: 16px; color: #e0e7ff; margin-bottom: 32px; font-family: Inter, sans-serif;">Join hundreds of satisfied customers today.</p>
          <a href="#" style="display: inline-block; padding: 14px 32px; background: #fff; color: #4f46e5; border-radius: 12px; text-decoration: none; font-weight: 600; font-family: Inter, sans-serif;">Start Now</a>
        </section>
      `,
    })

    bm.add("testimonial-section", {
      label: "Testimonials",
      category: "Sections",
      content: `
        <section style="padding: 60px 40px; background: #0f172a;">
          <h2 style="text-align: center; font-size: 32px; font-weight: 700; color: #f8fafc; margin-bottom: 48px; font-family: Inter, sans-serif;">What Our Clients Say</h2>
          <div style="display: flex; gap: 24px; flex-wrap: wrap; justify-content: center; max-width: 800px; margin: 0 auto;">
            <div style="flex: 1; min-width: 300px; padding: 32px; background: #1e293b; border-radius: 16px; border: 1px solid #334155;">
              <p style="font-size: 15px; color: #cbd5e1; margin-bottom: 16px; font-style: italic; font-family: Inter, sans-serif;">"This product completely transformed how we work. Highly recommended!"</p>
              <div style="display: flex; align-items: center; gap: 12px;">
                <div style="width: 40px; height: 40px; background: #6366f1; border-radius: 50%;"></div>
                <div>
                  <p style="font-size: 14px; font-weight: 600; color: #f8fafc; font-family: Inter, sans-serif;">Jane Doe</p>
                  <p style="font-size: 12px; color: #64748b; font-family: Inter, sans-serif;">CEO, Example Corp</p>
                </div>
              </div>
            </div>
            <div style="flex: 1; min-width: 300px; padding: 32px; background: #1e293b; border-radius: 16px; border: 1px solid #334155;">
              <p style="font-size: 15px; color: #cbd5e1; margin-bottom: 16px; font-style: italic; font-family: Inter, sans-serif;">"Outstanding service and support. Our results have been incredible."</p>
              <div style="display: flex; align-items: center; gap: 12px;">
                <div style="width: 40px; height: 40px; background: #06b6d4; border-radius: 50%;"></div>
                <div>
                  <p style="font-size: 14px; font-weight: 600; color: #f8fafc; font-family: Inter, sans-serif;">John Smith</p>
                  <p style="font-size: 12px; color: #64748b; font-family: Inter, sans-serif;">Founder, Startup Inc</p>
                </div>
              </div>
            </div>
          </div>
        </section>
      `,
    })

    bm.add("contact-section", {
      label: "Contact Form",
      category: "Sections",
      content: `
        <section style="padding: 60px 40px; background: #1e293b;">
          <div style="max-width: 500px; margin: 0 auto;">
            <h2 style="text-align: center; font-size: 32px; font-weight: 700; color: #f8fafc; margin-bottom: 8px; font-family: Inter, sans-serif;">Get in Touch</h2>
            <p style="text-align: center; font-size: 14px; color: #94a3b8; margin-bottom: 32px; font-family: Inter, sans-serif;">We'd love to hear from you.</p>
            <form style="display: flex; flex-direction: column; gap: 16px;">
              <input type="text" placeholder="Your Name" style="padding: 12px 16px; background: #0f172a; border: 1px solid #334155; border-radius: 8px; color: #f8fafc; font-size: 14px; font-family: Inter, sans-serif;">
              <input type="email" placeholder="Your Email" style="padding: 12px 16px; background: #0f172a; border: 1px solid #334155; border-radius: 8px; color: #f8fafc; font-size: 14px; font-family: Inter, sans-serif;">
              <textarea placeholder="Your Message" rows="4" style="padding: 12px 16px; background: #0f172a; border: 1px solid #334155; border-radius: 8px; color: #f8fafc; font-size: 14px; font-family: Inter, sans-serif; resize: vertical;"></textarea>
              <button type="submit" style="padding: 14px; background: #6366f1; color: #fff; border: none; border-radius: 8px; font-weight: 600; font-size: 14px; cursor: pointer; font-family: Inter, sans-serif;">Send Message</button>
            </form>
          </div>
        </section>
      `,
    })

    bm.add("footer-section", {
      label: "Footer",
      category: "Sections",
      content: `
        <footer style="padding: 40px; background: #020617; border-top: 1px solid #1e293b;">
          <div style="display: flex; justify-content: space-between; flex-wrap: wrap; gap: 32px; max-width: 1000px; margin: 0 auto;">
            <div>
              <h3 style="font-size: 18px; font-weight: 700; color: #f8fafc; margin-bottom: 8px; font-family: Inter, sans-serif;">Brand</h3>
              <p style="font-size: 13px; color: #64748b; max-width: 250px; font-family: Inter, sans-serif;">A short tagline about your brand or company.</p>
            </div>
            <div>
              <h4 style="font-size: 13px; font-weight: 600; color: #94a3b8; text-transform: uppercase; letter-spacing: 1px; margin-bottom: 12px; font-family: Inter, sans-serif;">Links</h4>
              <div style="display: flex; flex-direction: column; gap: 8px;">
                <a href="#" style="font-size: 14px; color: #64748b; text-decoration: none; font-family: Inter, sans-serif;">About</a>
                <a href="#" style="font-size: 14px; color: #64748b; text-decoration: none; font-family: Inter, sans-serif;">Services</a>
                <a href="#" style="font-size: 14px; color: #64748b; text-decoration: none; font-family: Inter, sans-serif;">Contact</a>
              </div>
            </div>
            <div>
              <h4 style="font-size: 13px; font-weight: 600; color: #94a3b8; text-transform: uppercase; letter-spacing: 1px; margin-bottom: 12px; font-family: Inter, sans-serif;">Legal</h4>
              <div style="display: flex; flex-direction: column; gap: 8px;">
                <a href="#" style="font-size: 14px; color: #64748b; text-decoration: none; font-family: Inter, sans-serif;">Privacy</a>
                <a href="#" style="font-size: 14px; color: #64748b; text-decoration: none; font-family: Inter, sans-serif;">Terms</a>
              </div>
            </div>
          </div>
          <div style="text-align: center; margin-top: 32px; padding-top: 24px; border-top: 1px solid #1e293b;">
            <p style="font-size: 12px; color: #475569; font-family: Inter, sans-serif;">&copy; 2026 Brand. All rights reserved.</p>
          </div>
        </footer>
      `,
    })
  }

  // Device switching
  setDesktop() {
    this.editor.setDevice("Desktop")
    this.updateDeviceButtons(0)
  }

  setTablet() {
    this.editor.setDevice("Tablet")
    this.updateDeviceButtons(1)
  }

  setMobile() {
    this.editor.setDevice("Mobile")
    this.updateDeviceButtons(2)
  }

  updateDeviceButtons(activeIndex) {
    const buttons = this.deviceButtonsTarget.querySelectorAll("button")
    buttons.forEach((btn, i) => {
      if (i === activeIndex) {
        btn.classList.add("bg-indigo-600", "text-slate-50")
        btn.classList.remove("text-slate-400")
      } else {
        btn.classList.remove("bg-indigo-600", "text-slate-50")
        btn.classList.add("text-slate-400")
      }
    })
  }

  // Undo/Redo
  undo() {
    this.editor.UndoManager.undo()
  }

  redo() {
    this.editor.UndoManager.redo()
  }

  // Panel switching
  showBlocks() {
    this.activatePanel("blocks")
  }

  showLayers() {
    this.activatePanel("layers")
  }

  showStyles() {
    this.activatePanel("styles")
  }

  showTraits() {
    this.activatePanel("traits")
  }

  activatePanel(name) {
    const panels = {
      blocks: this.blocksPanelTarget,
      layers: this.layersPanelTarget,
      styles: this.stylesPanelTarget,
      traits: this.traitsPanelTarget,
    }

    // Hide all panels
    Object.values(panels).forEach((el) => el.classList.add("hidden"))

    // Show selected
    panels[name].classList.remove("hidden")

    // Update button styles
    const panelNames = ["blocks", "layers", "styles", "traits"]
    this.panelBtnTargets.forEach((btn, i) => {
      if (panelNames[i] === name) {
        btn.classList.add("bg-indigo-600", "text-slate-50")
        btn.classList.remove("text-slate-400", "hover:text-slate-50", "hover:bg-slate-800")
      } else {
        btn.classList.remove("bg-indigo-600", "text-slate-50")
        btn.classList.add("text-slate-400", "hover:text-slate-50", "hover:bg-slate-800")
      }
    })
  }
}
