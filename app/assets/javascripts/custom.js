(function ($) {

    isEmptyValue = function(value) {
      return ( undefined === value || null === value || "" === value || ("" === value.replace(/[\n\r]/g, '')) )
    }

    myForm = function() {
      return $("form#myForm");
    };

    // Note: EpicEditor requires just the id value not a jquery selector
    // like "#myTextEpicEditor"
    myFormEpicEditorContainerId = function() {
      return "myTextEpicEditor";
    }

    // Note: EpicEditor requires just the id value not a jquery selector
    // like "#myTextArea"
    myFormTextAreaId = function() {
      return "myTextArea";
    }

    myFormMyTextLocalStorageName = function() {
      return "myTextEpicEditorLocalStorage";
    }

    myFormMyTextBodyFileName = function() {
      return "myTextFile";
    }

    myFormEpicEditorOpts = function() {
      var myTextEpicEditorOpts = {
        container: myFormEpicEditorContainerId(),
        textarea: myFormTextAreaId(),
        localStorageName: myFormMyTextLocalStorageName(),
        file: {
          name: myFormMyTextBodyFileName(),
          defaultContent: '',
          autoSave: 100
        },
      };
      return myTextEpicEditorOpts;
    }

    loadEpicEditorOnMyForm = function() {
      var selector = "#" + myFormEpicEditorContainerId();
      if ($(selector).length == 0) {
        return;
      }

      var myFormEpicEditorInstance = new EpicEditor(myFormEpicEditorOpts()).load();
    };

    bindClickEventOnSaveBtnOnMyForm = function() {
      var saveBtnObj = $("#saveBtn");

      if (saveBtnObj.length == 0) {
        return;
      }

      saveBtnObj.off("click").on("click", function(event) {
        var myFormObj = myForm();

        var myFormEpicEditorInstance = new EpicEditor(myFormEpicEditorOpts());

        // console.log(myFormEpicEditorInstance);

        var myText = myFormEpicEditorInstance.exportFile(myFormMyTextBodyFileName(), 'text');

        // console.log(myText);

        if (isEmptyValue(myText)) {
          alert("Please enter text");
          event.stopPropagation();
          return false;
        }

        myFormObj.submit();
      });
    };

    // Used for rendering EpicEditor in ONLY preview mode with only
    // full screen button and when the epic editor is switched to
    // full screen mode it hides the editor pane.
    displaySavedMyTextPreview = function() {
      var myDetailsView = $("#myDetailsView")

      if (myDetailsView.length == 0) {
        return;
      };

      var viewMyTextEpicEditorOpts = {
        container: 'viewMyTextBodyEpicEditor',
        textarea: 'viewMyTextTextArea',
        button: {
          preview: false,
          edit: false,
          fullscreen: true,
          bar: "auto"
        },
      };

      var viewMyTextEpicEditorInstance = new EpicEditor(viewMyTextEpicEditorOpts);
      viewMyTextEpicEditorInstance.load(function() {
        console.log("loaded");
        viewMyTextEpicEditorInstance.preview();
      });

      viewMyTextEpicEditorInstance.on('fullscreenenter', function() {
        // console.log("full screen enter");
        $(viewMyTextEpicEditorInstance.getElement('editorIframe')).hide();
      });
    };


  }) (jQuery);

  var ready;

  ready = function() {
    loadEpicEditorOnMyForm();
    bindClickEventOnSaveBtnOnMyForm();
    displaySavedMyTextPreview();
  };

  $(document).ready(ready);
  $(document).on('page:load', ready);
