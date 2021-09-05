<template>
<div>
  <select v-model="sel_channel">
    <option v-for="option in Object.keys(Channels)" v-bind:value="option">
      {{ option }}
    </option>
  </select>
  <br>
  <div class="row">
    <div class="col-md-7">
      <h3>Channel overview</h3>
      <p>Type: {{SelChannel.Type}}, HIV: {{(SelChannel.Pr_HIV === 0)?"Non-HIV": "PLHIV"}}</p>
      <p>Footfalls= {{SelChannel.N_Footfall.toLocaleString()}} (Unique= {{SelChannel.N_Unique.toLocaleString()}})</p>
      <p>Population growth= {{(SelChannel.Growth * 100).toFixed(2) + "%"}}, TB decline= {{(SelChannel.ADR * 100).toFixed(2) + "%"}}</p>
    </div>
    <div class="col-md-5">
      <table class="table">
        <thead>
        <tr>
          <th scope="col">#</th>
          <th scope="col">TB</th>
          <th scope="col">Non-TB</th>
        </tr>
        </thead>
        <tbody>
        <tr>
          <th scope="row">No TB symptom</th>
          <td>{{ (Groups["TB"][0] * 100).toFixed(2) + "%" }}</td>
          <td>{{ (Groups["OT"][0] * 100).toFixed(2) + "%" }}</td>
        </tr>
        <tr>
          <th scope="row">With TB symptoms</th>
          <td>{{ (Groups["TB"][1] * 100).toFixed(2) + "%" }}</td>
          <td>{{ (Groups["OT"][1] * 100).toFixed(2) + "%" }}</td>
        </tr>
        </tbody>
      </table>
    </div>
  </div>
  <h3>Pathways</h3>
  <div v-for="pathway in SelPathways">
    <b-button block v-b-toggle="'accordion-' + pathway.PID" variant="outline-dark">
      Pathway: {{ pathway.PID }}, Proportion: {{ (pathway.SOC.Proportion * 100).toFixed(0) + "%" }}
    </b-button>
    <b-collapse v-bind:id="'accordion-' + pathway.PID" class="mt-2">
      <div class="row">
        <div class="col-md-9">
          <p>Algorithms</p>
          <b-table :items="[pathway.SOC, pathway.ALT]" :fields="FieldPathway"></b-table>

          <p>LTFUs</p>
          <b-table :items="[pathway.LTFU_SOC, pathway.LTFU_ALT]" fields="['Arm', 'Initial', 'Screening', 'Sample', 'Traige']"></b-table>
        </div>
        <div class="col-md-3">
          <p>Uptake</p>
          <b-table :items="pathway.Uptake" :fields="['Year', 'l', 'm', 'u']"></b-table>
        </div>
      </div>
    </b-collapse>
  </div>

  <h3>Included tools</h3>
  <div>
    <b-table :items="SelTools" :fields="['Stage', 'Tool', 'Sensitivity', 'Specificity', 'Cost', 'Group']"></b-table>
  </div>
</div>
</template>

<script>
import _ from "lodash";


export default {
  name: "inputs",
  props: {
    src: Object
  },
  data: function() {
    return {
      Channels: this.src.Channels,
      Algorithms: this.src.Algorithms,
      Tools: this.src.Tools,
      Uptakes: this.src.Uptakes,
      MapLTFU: this.src.MapLTFUs,
      LTFUs: this.src.LTFUs,
      sel_channel: "Channel 1",
      FieldPathway: [{key: "Group", label: "Arm"}, 'Screen', 'Triage', 'NAAT_Sample', 'Confirm', 'TuTT']
    }
  },
  computed: {
    SelChannel: function() {
      return this.Channels[this.sel_channel]
    },
    SelPathways: function() {
      const algs = this.Algorithms[this.sel_channel]
      let alt, soc, uptake;

      const n_pathways = algs.length / 2;

      const pathways = [];
      for(let i = 1; i <= n_pathways; i ++) {
        soc = algs.find(alg => alg.Pathway === i && alg.Group === "SOC")
        alt = algs.find(alg => alg.Pathway === i && alg.Group === "ALT");
        uptake = [];
        for (let j = 2022; j < 2028; j++) {
          if (j < alt.AlternativeYear0) {
            uptake.push({Year: j, m: 0, l: 0, u: 0})
          } else {
            let k = j - alt.AlternativeYear0 + 1;
            k = Math.min(k, 5);

            uptake.push({
              Year: j,
              m: (this.Uptakes[alt.Uptake].m[k] * 100).toFixed(0) + "%",
              l: (this.Uptakes[alt.Uptake].l[k] * 100).toFixed(0) + "%",
              u: (this.Uptakes[alt.Uptake].u[k] * 100).toFixed(0) + "%"
            })
          }
        }

        pathways.push({
          PID: i,
          SOC: soc,
          ALT: alt,
          LTFU_SOC: this.identify_ltfu(soc),
          LTFU_ALT: this.identify_ltfu(alt),
          Uptake: uptake
        })
      }

      return pathways;
    },
    SelTools: function() {
      let screen = this.Algorithms[this.sel_channel].map(d => d.Screen)
      let triage = this.Algorithms[this.sel_channel].map(d => d.Triage)
      let confirm = this.Algorithms[this.sel_channel].map(d => d.Confirm)

      const tools = _.flatten([
            [... new Set(screen)].map(d => {return {Stage: "Screen", Tool: d}}),
            [... new Set(triage)].map(d => {return {Stage: "Triage", Tool: d}}),
            [... new Set(confirm)].map(d => {return {Stage: "Confirm", Tool: d}})
          ])

      tools.forEach(tool => {
        const src = this.Tools.find(t => t.Tool === tool.Tool);
        tool.Sensitivity = (this.SelChannel.Pr_HIV === 0)? src.NonHIV.Sensitivity: src.PLHIV.Sensitivity;
        tool.Specificity = (this.SelChannel.Pr_HIV === 0)? src.NonHIV.Specificity: src.PLHIV.Specificity;
        tool.Cost = src.Cost;
        tool.Group = src.CostGp;
      })

      return tools
    },
    Groups: function() {
      const tb = this.SelChannel.Pr_TB;
      const tb_asym = tb * this.SelChannel.Pr_AsymTB, tb_sym = tb - tb_asym;
      const ot_sym = this.SelChannel.Pr_Sym - tb_sym, ot_asym = 1 - tb - ot_sym;
      return {
        TB: [tb_asym, tb_sym],
        OT: [ot_asym, ot_sym]
      }
    }
  },
  methods: {
    identify_ltfu(pathway) {
      const screen = pathway.Screen, triage = pathway.Triage, confirm = pathway.Confirm, sample = pathway.NAAT_Sample;
      let ltfu_s, ltfu_t, ltfu_spu;

      if (screen === "None" && triage === "None" && confirm === "None") {
        ltfu_s = ltfu_t = ltfu_spu = "100%";
      } else if (triage === "None") {
        if (this.MapLTFU.Direct[confirm] !== undefined) {
          ltfu_t = this.MapLTFU.Direct[confirm];
        } else {
          ltfu_t = "0%";
        }
        ltfu_s = "0%"

        ltfu_spu = (sample === "Sputum")? "Scarcity": "0%";
      } else {
        if (this.MapLTFU.Direct[triage] !== undefined) {
          ltfu_s = this.MapLTFU.Direct[triage];
        } else {
          ltfu_s = "0%";
        }


        ltfu_t = this.MapLTFU.Triage[confirm];

        ltfu_spu = (sample === "Sputum")? "Scarcity": "0%";
      }

      return {
        Arm: pathway.Group,
        Initial: (this.LTFUs[this.sel_channel].InitialMissing_SOC * 100).toFixed(0) + "%",
        Screen: ltfu_s,
        Sample: ltfu_spu,
        Triage: ltfu_t
      }
    }
  }
}
</script>

<style scoped>

</style>