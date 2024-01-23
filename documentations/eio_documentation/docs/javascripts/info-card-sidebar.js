/* The info card is the content that appears above the Table of Contents of the right sidebar
on documents that follow specific templates (metric, conceptual guide, etc.) */

const docInfoPosition1 = document.getElementById('metric-template-info-main');
const docInfoPosition2 = document.querySelector('.md-sidebar--secondary #metric-template-info');

const conceptualGuideInfoPosition1 = document.getElementById('conceptual-guide-info-main');
const conceptualGuideInfoPosition2 = document.querySelector('.md-sidebar--secondary #conceptual-guide-info');

const datasetInfoPosition1 = document.getElementById('dataset-template-info-main');
const datasetInfoPosition2 = document.querySelector('.md-sidebar--secondary #dataset-template-info');

const howToInfoPosition1 = document.getElementById('how-to-template-info-main');
const howToInfoPosition2 = document.querySelector('.md-sidebar--secondary #how-to-template-info');

const dataImpactInfoPosition1 = document.getElementById('data-impact-assessment-template-info-main');
const dataImpactPosition2 = document.querySelector('.md-sidebar--secondary #data-impact-template-info');

const changeDocInfoPosition = () => {
  if (docInfoPosition1 && docInfoPosition2) {
    const content = docInfoPosition1.innerHTML;
    docInfoPosition1.innerHTML = '';
    docInfoPosition2.innerHTML = content;
  } else if (conceptualGuideInfoPosition1 && conceptualGuideInfoPosition2) {
    const conceptualGuideContent = conceptualGuideInfoPosition1.innerHTML;
    conceptualGuideInfoPosition1.innerHTML = '';
    conceptualGuideInfoPosition2.innerHTML = conceptualGuideContent;
  } else if (datasetInfoPosition1 && datasetInfoPosition2) {
    const datasetTemplateInfoContent = datasetInfoPosition1.innerHTML;
    datasetInfoPosition1.innerHTML = '';
    datasetInfoPosition2.innerHTML = datasetTemplateInfoContent;
  } else if (howToInfoPosition1 && howToInfoPosition2) {
    const howToTemplateInfoContent = howToInfoPosition1.innerHTML;
    howToInfoPosition1.innerHTML = '';
    howToInfoPosition2.innerHTML = howToTemplateInfoContent;
  } else if (dataImpactInfoPosition1 && dataImpactPosition2) {
  const dataImpactInfoContent = dataImpactInfoPosition1.innerHTML;
  dataImpactInfoPosition1.innerHTML = '';
  dataImpactPosition2.innerHTML = dataImpactInfoContent;
}
};

window.addEventListener('DOMContentLoaded', changeDocInfoPosition);

